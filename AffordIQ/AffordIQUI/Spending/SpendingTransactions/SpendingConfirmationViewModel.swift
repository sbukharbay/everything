//
//  SpendingConfirmationViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 17/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Amplitude
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class SpendingConfirmationViewModel {
    @Published var error: Error?
    @Published var isUserInteractionEnabled: Bool = true
    @Published var isLoading = false
    
    var showCompletionSubject = PassthroughSubject<Bool, Never>()
    var updateTableSubject = PassthroughSubject<Bool, Never>()
    var handleEvent: Publishers.HandleEvents<PassthroughSubject<Bool, Never>>?
    
    var spendingStack: [RecurringTransactionsModel]
    var currentSpending: RecurringTransactionsModel?
    var currentCategory: ChildCategoriesModel?
    var isInitial = true
    var savedSpendingData: [RecurringTransactionsModel]
    let getStartedType: GetStartedViewType
    
    private let transactionsSource: TransactionsSource
    let userSession: SessionType
    
    init(
        transactions: [RecurringTransactionsModel],
        getStartedType: GetStartedViewType,
        transactionsSource: TransactionsSource = TransactionsService(),
        userSession: SessionType = Auth0Session.shared
    ) {
        self.transactionsSource = transactionsSource
        self.userSession = userSession
        self.getStartedType = getStartedType
        
        spendingStack = []
        savedSpendingData = []
        Task {
            if transactions.isEmpty {
                await getSpendingTransactions()
            } else {
                await updateTransactionsList(with: transactions)
            }
        }
    }
    
    @MainActor
    func getSpendingTransactions() async {
        isLoading = true
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await transactionsSource.getTransactionsSpending(userID: userID)
            
            if !response.recurringPayments.isEmpty {
                updateTransactionsList(with: response.recurringPayments)
            }
            
            BusyView.shared.hide(success: true)
        } catch {
            self.error = error
            BusyView.shared.hide(success: false)
        }
        isLoading = false
    }
    
    @MainActor
    func updateTransactionsList(with transactions: [RecurringTransactionsModel]) {
        spendingStack = transactions
        currentSpending = transactions.first
        spendingStack.removeFirst()
        isInitial = false
        
        updateTableSubject
            .send(true)
    }

    func confirmTransaction(save: Bool) {
        if save, let current = currentSpending {
            savedSpendingData.append(current)
        }
        
        if let spending = spendingStack.first {
            currentSpending = spending
            spendingStack.removeFirst()
            
            updateTableSubject.send(true)
        } else {
            isUserInteractionEnabled = false
            showCompletionSubject.send(true)
            
            Amplitude.instance().logEvent(OnboardingStep.validateSpending.rawValue)
        }
    }

    func saveCategorisedTransactions() async {
        var spendings: [RMTransactionsRecategorise] = []
        
        if let transactions = currentSpending, let category = currentCategory {
            transactions.transactionsIdentifiers.forEach { identifiers in
                let transactionDetail = TransactionRecategoriseDetail(
                    accountId: identifiers.accountId,
                    amount: StringMonetaryAmount(amount: transactions.amount.amount?.floatValue.description),
                    description: transactions.transactionDescription,
                    transactionDateTime: identifiers.transactionDateTime
                )
                
                if spendings.contains(where: { $0.categoryId == category.categoryId }) {
                    spendings.enumerated().forEach { i, spending in
                        if spending.categoryId == category.categoryId {
                            if !spending.transactions.contains(where: { $0 == transactionDetail }) {
                                spendings[i].transactions.append(transactionDetail)
                            }
                        }
                    }
                } else {
                    spendings
                        .append(RMTransactionsRecategorise(transactions: [transactionDetail], categoryId: category.categoryId))
                }
            }
        }
        
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            try await transactionsSource.transactionsRecategorise(userID: userID, model: spendings)
        } catch {
            self.error = error
        }
    }
    
    deinit {
        print("[deinit SpendingConfirmationViewModel]")
    }
}
