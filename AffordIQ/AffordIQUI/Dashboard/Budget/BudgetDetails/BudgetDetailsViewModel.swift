//
//  BudgetDetailsViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03.10.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import AffordIQNetworkKit
import AffordIQAuth0

class BudgetDetailsViewModel {
    var spending: SpendingBreakdownCategory
    let styles: AppStyles
    private let goalSource: GoalSource
    private let session: SessionType
    
    @Published var error: Error?
    @Published var operationComplete: Bool = false
    
    init(
        session: SessionType = Auth0Session.shared, 
        goalSource: GoalSource = GoalService(),
        styles: AppStyles = AppStyles.shared,
        spending: SpendingBreakdownCategory
    ) {
        self.styles = styles
        self.spending = spending
        self.goalSource = goalSource
        self.session = session
    }

    @MainActor
    func setMonthlySavingsGoal(_ amount: MonetaryAmount) async {
        guard let id = session.userID else { return }
        
        let payload = [RMSpendingTarget(categoryId: spending.id, categoryName: spending.name, id: nil, monthlySpendingTarget: amount)]

        do {
            try await goalSource.setSpendingGoal(userID: id, model: payload)
            operationComplete = true
        } catch {
            self.error = error
        }
    }
}
