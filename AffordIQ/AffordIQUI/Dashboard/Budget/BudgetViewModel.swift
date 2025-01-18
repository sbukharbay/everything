//
//  BudgetViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 10.08.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

class BudgetViewModel {
    var budgetDetails: [BudgetDetailModel]
    var monthlySpending: MonthlyBudgetDetailsResponse?
    var leftToSpend: MonetaryAmount = .init(amount: 0)
    var savingsGoal: String = ""
    var discretionary: [SpendingBreakdownCategory]
    var nonDiscretionary: [SpendingBreakdownCategory]
    var monthlyBreakdownIsEmpty: Bool = false
    private let spendingSource: SpendingSource = SpendingService()
    private let affordabilitySource: AffordabilitySource = AffordabilityService()
    private var session: SessionType
    
    @Published var error: Error?
    @Published var hideOverlayTable: Bool?
    @Published var update: Bool?
    @Published var updateBottom: Bool?
    @Published var updateSpendingTable: Bool?
    
    var isSpendingAndCostsListEmpty: Bool {
        discretionary.isEmpty && nonDiscretionary.isEmpty
    }
    
    init(session: SessionType = Auth0Session.shared) {
        self.session = session
        
        budgetDetails = []
        discretionary = []
        nonDiscretionary = []

        resume()
    }

    func resume() {
        hideOverlayTable = true
        
        guard let id = session.userID else { return }
        
        Task {
            await getMonthlyBreakdown(id)
            await getMonthlySpending(id)
            await mortgageAffordability(id)
        }
    }
    
    @MainActor
    func getMonthlySpending(_ id: String) async {
        do {
            let spendings = try await spendingSource.getMonthlySpending(userID: id)
            
            monthlySpending = spendings
            leftToSpend = spendings.discretionary.leftToSpend
            budgetDetails = [BudgetDetailModel(icon: "spending_gradient", title: "Total Spending", value: spendings.totalSpend)]
            update = true
            await getIncome(id)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func mortgageAffordability(_ id: String) async {
        do {
            let affordability = try await affordabilitySource.getGoalTrackingAndMortgageLimits(userID: id)
            savingsGoal = affordability.savingsGoal?.monthlySavingsAmount?.shortDescription ?? "N/A"
        } catch {
            self.error = error
        }
    }

    @MainActor
    private func getIncome(_ id: String) async {
        do {
            let income = try await affordabilitySource.getIncomeStatus(userID: id)
            switch income.employmentStatus {
            case .employed:
                budgetDetails.append(BudgetDetailModel(icon: "income_gradient", title: "Income", value: income.monthlyNetSalary ?? MonetaryAmount(amount: 0.0)))
            default:
                let income = income.profitsAfterTax != MonetaryAmount(amount: 0.0) ? (income.profitsAfterTax ?? MonetaryAmount(amount: 0.0)) : (income.earningsAfterTax ?? MonetaryAmount(amount: 0.0))
                let value = income / 12
                budgetDetails.append(BudgetDetailModel(icon: "income_gradient", title: "Income", value: value))
            }
            
            updateBottom = true
        } catch {
            self.error = error
        }
    }

    @MainActor
    func getMonthlyBreakdown(_ id: String) async {
        do {
            let data = try await spendingSource.getMonthlyBreakdown(userID: id)
            
            discretionary = data.discretionary.sorted(by: { item1, item2 in
                item1.order < item2.order
            })
            nonDiscretionary = data.nonDiscretionary.sorted(by: { item1, item2 in
                item1.order < item2.order
            })
            
            updateSpendingTable = true
        } catch {
            if let error = error as? NetworkError {
                switch error {
                case .emptyResponseBody:
                    monthlyBreakdownIsEmpty = true
                default:
                    self.error = error
                }
            }
        }
    }
}
