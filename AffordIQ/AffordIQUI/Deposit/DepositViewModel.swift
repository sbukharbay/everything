//
//  DepositViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import Combine
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

struct DepositAccount: Equatable, Hashable {
    let account: InstitutionAccount
    var isSelected: Bool
}

protocol DepositView: AnyObject, ErrorPresenter {
    func set(currentDeposit: String?)
    func set(savings: NSAttributedString?)
    func set(externalCapitalAmount: MonetaryAmount?, externalCapitalDescription: String)
    func present(accounts: [DepositAccount], animated: Bool)
    func presentNext()
    func addAccounts(hide: Bool)
    func skip(hide: Bool)
    func back()
}

class DepositViewModel: NSObject {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    weak var view: DepositView?
    var subscriptions: Set<AnyCancellable> = []
    var externalCapital: ExternalCapitalResponse?
    private let depositSource: DepositSource
    private let userSource: UserSource
    private let userSession: SessionType
    private let accountsSource: AccountsSource

    init(view: DepositView,
         userSession: SessionType = Auth0Session.shared,
         accountsSource: AccountsSource = AccountsService(),
         depositSource: DepositSource = DepositService(),
         userSource: UserSource = UserService()
    ) {
        self.view = view
        self.userSession = userSession
        self.depositSource = depositSource
        self.userSource = userSource
        self.accountsSource = accountsSource
        
        super.init()
        
        Task {
            isLoading = true
            await getAccounts()
            await setDepositBalance()
            await setExternalCapital()
            isLoading = false
        }
    }
    
    func reload() {
        Task {
            isLoading = true
            await setDepositBalance()
            await setExternalCapital()
            isLoading = false
        }
    }
    
    @MainActor func setDepositBalance() async {
        let depositBalance = await getDepositBalance()
        var totalDeposit = MonetaryAmount(amount: 0.00)
        
        if let depositBalance = depositBalance {
            totalDeposit += depositBalance.depositBalance
        }
        
        view?.set(currentDeposit: totalDeposit.shortDescription)
        
        if let amount = totalDeposit.amount {
            view?.skip(hide: amount.doubleValue > 0)
        }
    }
    
    @MainActor func setExternalCapital() async {
        externalCapital = await getExternalCapital()
        var externalCapitalDescription = externalCapital?.description ?? ""
        
        if externalCapitalDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            externalCapitalDescription = NSLocalizedString("In addition to savings", bundle: uiBundle, comment: "In addition to savings")
        }
        
        view?.set(externalCapitalAmount: externalCapital?.externalCapitalAmount, externalCapitalDescription: externalCapitalDescription)
    }
    
    @MainActor func getAccounts() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await accountsSource.getAccounts(userID: userID)
            let accounts = response.institutionAccounts
            
            if accounts.isEmpty {
                view?.present(accounts: [], animated: false)
            } else {
                let depositAccounts = accounts
                    .filter { $0.accountType == .savings }
                    .sorted()
                    .map { DepositAccount(account: $0, isSelected: $0.usedForDeposit) }
                if depositAccounts.isEmpty {
                    view?.addAccounts(hide: false)
                } else {
                    view?.present(accounts: depositAccounts, animated: false)
                }
            }
        } catch {
            self.error = error
        }
    }
    
    @MainActor func getDepositBalance() async -> DepositBalanceResponse? {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            return try await depositSource.getBalance(userID: userID)
        } catch {
            self.error = error
            return nil
        }
    }
    
    @MainActor func getExternalCapital() async -> ExternalCapitalResponse? {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            return try await depositSource.getExternalCapital(userID: userID)
        } catch {
            self.error = error
            return nil
        }
    }

    @MainActor func deleteOutsideCapital() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            isLoading = true
            try await depositSource.deleteExternalCapital(userID: userID)
            isLoading = false
            reload()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func updateAccounts(contributesToDeposit: [String], doesNotContributeToDeposit: [String], completion: @escaping (Bool) -> Void) async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let model = RMAccountsUsedForDeposit(
                contributesToDeposit: contributesToDeposit,
                doesNotContributeToDeposit: doesNotContributeToDeposit,
                userID: userID
            )
            
            try await depositSource.updateAccounts(model: model)
            await setDepositBalance()
            
            completion(true)
        } catch {
            self.error = error
        }
    }
    
    func confirm() async {
        do {
            try await confirmSavings()
            try await checkCurrentState()
            await MainActor.run {
                view?.presentNext()
            }
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func confirmSavings() async throws {
        guard let userID = userSession.userID else { throw NetworkError.unauthorized }
        try await depositSource.confirmSavings(userID: userID)
    }

    @MainActor
    func checkCurrentState() async throws {
        guard let userID = userSession.userID else { throw NetworkError.unauthorized }
        let response = try await userSource.getUserStatus(userID: userID)
        switch response.nextStep {
        case .validateSpending:
            Amplitude.instance().logEvent(OnboardingStep.addSavingsInfo.rawValue)
        default:
            break
        }
    }
}
