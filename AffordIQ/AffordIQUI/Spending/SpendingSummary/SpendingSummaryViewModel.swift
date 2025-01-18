//
//  SpendingSummaryViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 10/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

enum TransactionTypes: String {
    case nonDiscretionary = "Non-discretionary"
    case discretionary = "Discretionary"
    case banking = "Banking"
    
    var value: String {
        rawValue
    }
}

class SpendingSummaryViewModel {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    var updateTableSubject = PassthroughSubject<Bool, Never>()
    var spendingCategories: AverageSpendingSummaryResponse?
    var averageCategorisedTransactions: [AverageCategorisedTransactionsModel] = []
    var isSelected = false
    var selectedRow: CategorisedTransactionsSummariesModel?
    var subCategoryData: AverageSubCategorySpendingSummaryResponse?
    var getStartedType: GetStartedViewType = .spending
    var isRecategorisationFlow = false
    var isSettings: Bool
    let spendingSource: SpendingSource
    let userSession: SessionType
    
    var isOnboardingCategorisationDone: Bool {
        get {
            AccountsManager.shared.isOnboardingCategorisationDone
        } set {
            AccountsManager.shared.isOnboardingCategorisationDone = newValue
        }
    }
    
    init(getStartedType: GetStartedViewType? = nil,
         spendingSource: SpendingSource = SpendingService(),
         userSession: SessionType = Auth0Session.shared,
         isSettings: Bool
    ) {
        self.spendingSource = spendingSource
        self.userSession = userSession
        self.isSettings = isSettings

        if let type = getStartedType {
            self.getStartedType = type
        }

        Task {
            isLoading = true
            await getAverageMonthlySpending()
            isLoading = false
        }
    }

    @MainActor
    func getAverageMonthlySpending() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await spendingSource.getSpendingSummary(userID: userID)
            
            spendingCategories = response
            averageCategorisedTransactions = getCategorisedTransactions(data: response)
            
            updateTableSubject.send(true)
        } catch {
            if let error = error as? NetworkError, error == .emptyBody {
                updateTableSubject.send(true)
            } else {
                self.error = error
            }
        }
    }

    func getCategorisedTransactions(data: AverageSpendingSummaryResponse) -> [AverageCategorisedTransactionsModel] {
        var transactions: [AverageCategorisedTransactionsModel] = []

        if let transaction = data.averageCategorisedTransactions.first(where: { $0.categorisedTransactionsType == TransactionTypes.nonDiscretionary.value }) {
            transactions.append(transaction)
        }
        if let transaction = data.averageCategorisedTransactions.first(where: { $0.categorisedTransactionsType == TransactionTypes.discretionary.value }) {
            transactions.append(transaction)
        }
        if let transaction = data.averageCategorisedTransactions.first(where: { $0.categorisedTransactionsType == TransactionTypes.banking.value }) {
            transactions.append(transaction)
        }

        return transactions
    }

    func fetchSubCategory(for parentCategoryID: Int) async {
        isLoading = true
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            subCategoryData = try await spendingSource.getSpendingSubcategories(userID: userID, categoryID: parentCategoryID)
            
            updateTableSubject.send(true)
        } catch {
            self.error = error
        }
        isLoading = false
    }

    func getAverageMonthlySpendingSubCategories(parentCategoryID: Int) async throws -> AverageSubCategorySpendingSummaryResponse {
        guard let userID = userSession.userID else { throw NetworkError.unauthorized }
        let response = try await spendingSource.getSpendingSubcategories(userID: userID, categoryID: parentCategoryID)
        
        return response
    }
}
