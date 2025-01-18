//
//  SetSpendingGoalViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 24/02/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class SetSavingsGoalViewModel {
    @Published var error: Error?
    @Published var surplus: MonetaryAmount?
    @Published var isLoading: Bool = false
    @Published var isDone: Bool = false
    
    var isDashboard: Bool
    
    private let goalSource: GoalSource
    private let spendingSource: SpendingSource
    private let userSession: SessionType
    let changeSliderSubject = PassthroughSubject<Float, Never>()
    let setupViewsForZeroSurplusSubject = PassthroughSubject<Bool, Never>()
    let setSurplusSubject = PassthroughSubject<Bool, Never>()
    let operationCompleteSubject = PassthroughSubject<Bool, Never>()
    
    init(isDashboard: Bool,
         goalSource: GoalSource = GoalService(),
         spendingSource: SpendingSource = SpendingService(),
         userSession: SessionType = Auth0Session.shared
    ) {
        self.isDashboard = isDashboard
        self.goalSource = goalSource
        self.spendingSource = spendingSource
        self.userSession = userSession
        
        Task {
            isLoading = true
            await updateSurplus()
            isLoading = false
        }
    }
                
    func updateSurplus() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await spendingSource.getSpendingSurplus(userID: userID)
            surplus = response.surplus
            
            await updateGoal()
            
            if response.surplus <= MonetaryAmount(amount: 0) {
                setupViewsForZeroSurplusSubject.send(true)
            }
            setSurplusSubject.send(true)
        } catch {
            if error as? NetworkError == .unauthorized {
                self.error = error
            } else {
                setupViewsForZeroSurplusSubject.send(true)
            }
        }
    }

    func updateGoal() async {
        let goal = await getSavingsGoal()
        
        if let surplus = surplus?.amount?.floatValue, let goal {
            if goal > surplus {
                changeSliderSubject.send(surplus / 2)
            } else {
                changeSliderSubject.send(goal)
            }
        }
    }

    @MainActor
    func getSavingsGoal() async -> Float? {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await goalSource.getAllGoals(userID: userID)
            let monthlySavingsAmount = response.savingsGoal?.monthlySavingsAmount?.amount?.floatValue
            
            return monthlySavingsAmount
        } catch NetworkError.emptyBody {
            if let surplus = surplus?.amount?.floatValue {
                changeSliderSubject.send(surplus / 2)
            }
        } catch {
            changeSliderSubject.send(0)
        }
        
        return nil
    }

    func setSavingsGoal(savingsGoal: String) {
        let goal = savingsGoal.dropFirst()
        let goalToString = String(goal)
        let removeCommaInString = goalToString.split(separator: ",").joined()
        let stringToDecimal = Decimal(string: removeCommaInString)

        let data = RMSavingGoalSet(monthlySavingsAmount: MonetaryAmount(amount: stringToDecimal))

        Task {
            isDone = true
            await postSavingsGoal(model: data)
            isDone = false
        }
    }

    @MainActor
    func postSavingsGoal(model: RMSavingGoalSet) async {
        
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            try await goalSource.savingsGoal(userID: userID, model: model)
            operationCompleteSubject.send(true)
        } catch {
            self.error = error
        }
    }
}
