//
//  SavingBudgetViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 29/06/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import Foundation
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class SavingBudgetViewModel {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    let updateSubject = PassthroughSubject<Void, Never>()
    let updateTableSubject = PassthroughSubject<Void, Never>()
    let onboardingCompleteSubject = PassthroughSubject<Void, Never>()
    
    var months = 0
    var savingsPerMonth: MonetaryAmount?
    var surplus: MonetaryAmount?
    var isDashboard: Bool
    var topCategories: [TopAverageSpendingModel] = []
    var currentIndex = 0
    var currentSpend = 0
    var overallAdditionalSavings = 0
    var currentAdditionalSavings = 0
    var savedCategories: [RMSpendingTarget] = []
    
    private let affordabilitySource: AffordabilitySource
    private let spendingSource: SpendingSource
    private let goalSource: GoalSource
    private let userSession: SessionType
    private let amplitude: AmplitudeProtocol
    
    init(isDashboard: Bool = false,
         affordabilitySource: AffordabilitySource = AffordabilityService(),
         spendingSource: SpendingSource = SpendingService(),
         goalSource: GoalSource = GoalService(),
         userSession: SessionType = Auth0Session.shared,
         amplitude: AmplitudeProtocol = Amplitude.instance()
    ) {
        self.isDashboard = isDashboard
        self.affordabilitySource = affordabilitySource
        self.spendingSource = spendingSource
        self.goalSource = goalSource
        self.userSession = userSession
        self.amplitude = amplitude
        
        Task {
            isLoading = true
            
            await getMonthsUntilAffordableData()
            await getSpendingSurplus()
            await getTopCategories()
            
            isLoading = false
        }
    }

    @MainActor
    func getMonthsUntilAffordableData() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await affordabilitySource.getGoalTrackingAndMortgageLimits(userID: userID)
            
            months = response.monthsUntilAffordable ?? 0
            savingsPerMonth = response.savingsGoal?.monthlySavingsAmount ?? MonetaryAmount(amount: 0)
            
            updateSubject.send()
        } catch {
            if let error = error as? NetworkError, error == .emptyBody {
                updateSubject.send()
            } else {
                self.error = error
            }
        }
    }

    @MainActor
    func getSpendingSurplus() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await spendingSource.getSpendingSurplus(userID: userID)
            surplus = response.surplus
            
            updateSubject.send()
        } catch {
            if let error = error as? NetworkError, error == .emptyBody {
                updateSubject.send()
            } else {
                self.error = error
            }
        }
    }

    @MainActor
    func getTopCategories() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await spendingSource.getTopFourSpendingCategories(userID: userID)
            topCategories = response.topMonthlyAverageSpending
            
            response.topMonthlyAverageSpending.enumerated().forEach { index, spending in
                if let spendingGoal = spending.spendingGoal?.amount?.doubleValue {
                    let currentSave = Int((spending.averageSpend.amount?.doubleValue ?? spendingGoal) - spendingGoal)
                    topCategories[index].savedAmount = currentSave
                    overallAdditionalSavings += currentSave
                }
            }
            
            spendingGoalCheck()
            updateTableSubject.send()
        } catch {
            if let error = error as? NetworkError, error == .emptyBody {
                updateTableSubject.send()
            } else {
                self.error = error
            }
        }
    }

    func spendingGoalCheck() {
        if topCategories[currentIndex].spendingGoal != nil {
            currentSpend = Int(topCategories[currentIndex].spendingGoal?.amount?.doubleValue ?? 0)
        } else {
            currentSpend = Int(topCategories[currentIndex].averageSpend.amount?.doubleValue ?? 0)
        }
    }

    func confirmNewSpendingTarget() {
        let current = topCategories[currentIndex]
        
        if let index = savedCategories.firstIndex(where: { $0.categoryId == current.categoryId }) {
            savedCategories[index].monthlySpendingTarget = MonetaryAmount(amount: current.spendingGoal?.amount)
        } else {
            savedCategories.append(RMSpendingTarget(categoryId: current.categoryId, categoryName: current.categoryName, id: current.categoryId, monthlySpendingTarget: MonetaryAmount(amount: current.spendingGoal?.amount)))
        }
    }

    @MainActor
    func setMonthlySavingsGoal() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            try await goalSource.setSpendingGoal(userID: userID, model: savedCategories)
            onboardingCompleteSubject.send()
        } catch {
            self.error = error
        }
    }
    
    func onboardingCompleteStep() {
        amplitude.logEvent(key: OnboardingStep.completeBudget.rawValue)
    }
}
