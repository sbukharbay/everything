//
//  AccountDetailsViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 04/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Combine
import UIKit
import AffordIQNetworkKit
import AffordIQControls
import AffordIQAuth0
import AffordIQFoundation

protocol AccountDetailsView: AnyObject {
    func present(content: [[AccountDetailsViewContent]])
}

enum AccountDetailsViewContent: Hashable {
    case account(account: InstitutionAccount)
    case expiry(content: String)
    case disconnect
    case reconsent
    case consentHeader
    case consent(consent: OpenBankingConsent.ConsentScope)
}

class AccountDetailsViewModel: NSObject {
    @Published var error: Error?
    var willReconsent: Bool = false
    var account: InstitutionAccount
    weak var view: AccountDetailsView?
    var isLastAccount: Bool
    private var institutionAccounts: [InstitutionAccount]
    
    private var accountsSource: AccountsSource
    private var userSession: SessionType

    init(view: AccountDetailsView,
         account: InstitutionAccount,
         institutionAccounts: [InstitutionAccount],
         accountsSource: AccountsSource = AccountsService(),
         userSession: SessionType = Auth0Session.shared,
         isLast: Bool
    ) {
        self.view = view
        self.account = account
        self.accountsSource = accountsSource
        self.userSession = userSession
        self.isLastAccount = isLast
        self.institutionAccounts = institutionAccounts

        super.init()

        checkConsent()
    }
    
    @MainActor
    func updateAccount() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await accountsSource.getAccounts(userID: userID)
            
            account.consent = response.openBankingConsents?.first(where: { $0.providerId == account.institutionId })
            checkConsent()
        } catch {
        }
    }

    func updateContent() {
        var content: [[AccountDetailsViewContent]] = []

        guard let consent = account.consent else {
            content.append(expiryContent(consent: nil) + (isLastAccount ? [] : [.disconnect]))
            view?.present(content: content)
            return
        }
        
        if willReconsent {
            content.append(expiryContent(consent: nil) + [.reconsent] + (isLastAccount ? [] : [.disconnect]))
        } else {
            content.append(expiryContent(consent: consent) + (isLastAccount ? [] : [.disconnect]))
        }
        view?.present(content: content)
    }
    
    @MainActor
    func disconnect(all: Bool, completion: @escaping (Bool) -> Void) {
        Task {
            var remainingLinkedAccounts: [InstitutionAccount] = []
            if !all {
                remainingLinkedAccounts = institutionAccounts.filter { $0.accountId != account.accountId }
            }

            let isSuccess = await linkAccounts(of: account.institutionId, withAccounts: remainingLinkedAccounts)
            
            completion(isSuccess)
        }
    }
    
    @MainActor
    func linkAccounts(of institutionID: String, withAccounts accounts: [InstitutionAccount]) async -> Bool {
        guard let userID = userSession.userID else { return false }
        let accountsToLink = accounts.map { $0.accountId }
        let accountsRequest = RMLinkAccounts(
            accountInstitutionID: institutionID,
            accountsToLink: accountsToLink,
            userID: userID
        )
        
        do {
            try await accountsSource.link(model: accountsRequest)
            return true
        } catch {
            self.error = error
            return false
        }
    }
    
    private func expiryContent(consent: OpenBankingConsent?) -> [AccountDetailsViewContent] {
        let firstParagraph = NSLocalizedString(
            """
            To provide you with meaningful financial insights, affordIQ needs continuous access to the following information from this account.
            • Full Name
            • Account Number and Sort Code
            • Balance
            • Transactions
            """,
            bundle: uiBundle,
            comment:
            """
            To provide you with meaningful financial insights, affordIQ needs continuous access to the following information from this account.
            • Full Name
            • Account Number and Sort Code
            • Balance
            • Transactions
            """
        )
        guard let consent = consent else {
            return [.expiry(content: firstParagraph)]
        }
        
        let secondParagraph = describe(consent: consent)
        let content = firstParagraph + .paragraphBreak + secondParagraph
        
        return [.expiry(content: content)]
    }
    
    private func describe(consent: OpenBankingConsent) -> String {
        var secondParagraphFormat = NSLocalizedString(
            "Permission was granted on %1$@ and will expire on %2$@. We will let you know when you need to renew your consent.",
            bundle: uiBundle,
            comment: "Permission was granted on %1$@ and will expire on %2$@. We will let you know when you need to renew your consent.")
        if consent.consentExpires < systemDate {
            secondParagraphFormat = NSLocalizedString(
                "Permission was granted on %1$@ and expired on %2$@. Re-authentication is required for continued access.",
                bundle: uiBundle,
                comment: "Permission was granted on %1$@ expired on %2$@ Re-authentication is required for continued access.")
        }

        let dateFormatter = DateFormatter()
        #if DEBUG
        dateFormatter.timeStyle = .short
        #else
        dateFormatter.timeStyle = .none
        #endif
        dateFormatter.dateStyle = .full
        
        let result = String.localizedStringWithFormat(
            secondParagraphFormat,
            dateFormatter.string(from: consent.consentCreated),
            dateFormatter.string(from: consent.consentExpires)
        )

        return result
    }
    
    func checkConsent() {
        let period = Calendar.current.date(byAdding: .day, value: 21, to: Date())
        
        if let period, let consentExpires = account.consent?.consentExpires, consentExpires <= period {
            willReconsent = true
        }
        
        updateContent()
    }
}
