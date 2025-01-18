//
//  AccountsViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 02/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Combine
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

extension InstitutionAccount.AccountType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .businessCurrent:
            return NSLocalizedString("Business Current Accounts", bundle: uiBundle, comment: "Business Current Accounts")
        case .businessSavings:
            return NSLocalizedString("Business Savings Accounts", bundle: uiBundle, comment: "Business Savings Accounts")
        case .creditCard:
            return NSLocalizedString("Credit Cards", bundle: uiBundle, comment: "Credit Cards")
        case .current:
            return NSLocalizedString("Current Accounts", bundle: uiBundle, comment: "Current Accounts")
        case .savings:
            return NSLocalizedString("Savings Accounts", bundle: uiBundle, comment: "Savings Accounts")
        case .undefined:
            return NSLocalizedString("Other", bundle: uiBundle, comment: "Other")
        }
    }
    
    public var descriptionSingular: String {
        var type = description
        if description.last == "s" {
            type.removeLast()
        }
        return type
    }
}

class AccountsViewModel: NSObject {
    @Published var isLoading = false
    @Published var reconsent: Bool = false
    @Published var present: [[InstitutionAccount]] = []
    
    var getStartedType: GetStartedViewType = .linkedBankAccounts
    var addedSavings: Bool?
    var isSettings: Bool
    var isLastCurrentAccount: Bool = false
    var isLastSavingAccount: Bool = false

    private var accountsSource: AccountsSource
    private var userSession: SessionType
    
    var accountsAndConsents: [[InstitutionAccount]] = []
    var uniqueAccounts: [InstitutionAccount] = []
    
    init(getStartedType: GetStartedViewType? = nil,
         addedSavings: Bool? = nil,
         accountsSource: AccountsSource = AccountsService(),
         isSettings: Bool = false,
         userSessions: SessionType = Auth0Session.shared
    ) {
        self.addedSavings = addedSavings
        self.isSettings = isSettings
        self.accountsSource = accountsSource
        self.userSession = userSessions

        if let type = getStartedType {
            self.getStartedType = type
        }

        super.init()

        load()
    }
    
    func load() {
        Task {
            isLoading = true
            await getAccounts()
            isLoading = false
        }
    }
    
    func findAccount(with accountID: String) -> IndexPath? {
        for (sectionIndex, array) in present.enumerated() {
            if let rowIndex = array.firstIndex(where: { $0.accountId == accountID }) {
                present[sectionIndex].remove(at: rowIndex)
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        
        return nil
    }
    
    @MainActor
    func getAccounts() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await accountsSource.getAccounts(userID: userID)
            uniqueAccounts = Array(Set(response.institutionAccounts)).sorted()
            accountsAndConsents = []
            
            let accounts: [InstitutionAccount] = uniqueAccounts.map { account in
                
                var account = account
                
                account.consent = response.openBankingConsents?.first(where: { $0.providerId == account.institutionId })
                
                return account
            }

            var currentAccountsCounter = 0
            var savingAccountsCounter = 0
                          
            accounts.forEach { account in
                if account.accountType == .current {
                    currentAccountsCounter += 1
                } else {
                    savingAccountsCounter += 1
                }
            }
            isLastCurrentAccount = currentAccountsCounter == 1
            isLastSavingAccount = savingAccountsCounter == 1
            
            present = []
            present.append(accounts.filter { $0.accountNumber == nil })
            present.append(accounts.filter { $0.accountType == .current })
            present.append(accounts.filter { $0.accountType == .savings })
            
            let period = Calendar.current.date(byAdding: .day, value: 21, to: Date())
            
            response.openBankingConsents?.forEach { consent in
                if let period, consent.consentExpires <= period {
                    var bankAccounts = [InstitutionAccount]()
                    
                    uniqueAccounts.forEach { account in
                        if consent.providerId == account.institutionId {
                            var accountWithConsent = account
                            accountWithConsent.consent = consent
                            bankAccounts.append(accountWithConsent)
                        }
                    }
                    
                    if !bankAccounts.isEmpty {
                        accountsAndConsents.append(bankAccounts)
                        reconsent = true
                    } else {
                        reconsent = false
                    }
                }
            }
        } catch {
            print("[Error] [AccountsViewModel.getAccounts()]", error)
        }
    }
}
