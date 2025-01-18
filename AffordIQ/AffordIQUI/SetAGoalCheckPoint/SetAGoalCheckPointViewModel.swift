//
//  SetAGoalCheckPointViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 01/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class SetAGoalCheckPointViewModel {
    @Published var error: Error?
    @Published var isLoadingData: Bool = false
    // Send signal to update view
    let willUpdate = PassthroughSubject<Bool, Never>()
    
    var months = 0
    var viewType: SetAGoalCheckPointViewType = .savingGoal
    var getStartedType: GetStartedViewType = .goal
    var isBackAvailable: Bool
    let savingsGoalData: [Page] = [
        Page(imageName: "savings", headerText: "Savings", bodyText: ""),
        Page(imageName: "property", headerText: "Property", bodyText: "Search for a property you can afford in the area you wish to live."),
        Page(imageName: "deposit_goal", headerText: "Deposit", bodyText: "Set the size of the deposit and see how it will affect the time until you can buy."),
        Page(imageName: "repayments", headerText: "Budget", bodyText: "Set budget goals below to increase your monthly savings and complete your goal sooner.")
    ]
    
    private let source: AffordabilitySource
    private let userSession: SessionType

    init(viewType: SetAGoalCheckPointViewType,
         getStartedType: GetStartedViewType?,
         mortgageAffordabilitySource: AffordabilitySource = AffordabilityService(),
         userSession: SessionType = Auth0Session.shared,
         isBackAvailable: Bool
    ) {
        self.viewType = viewType
        self.source = mortgageAffordabilitySource
        self.userSession = userSession
        self.isBackAvailable = isBackAvailable
        
        if let type = getStartedType {
            self.getStartedType = type
        }
        
        if viewType != .savingGoal {
            Task {
                isLoadingData = true
                await getMonthsUntilAffordable()
                isLoadingData = false
            }
        }
    }

    @MainActor
    func getMonthsUntilAffordable() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let responce = try await source.getGoalTrackingAndMortgageLimits(userID: userID)
            months = responce.monthsUntilAffordable ?? 0
            willUpdate.send(true)
        } catch {
            self.error = error
        }
    }
}
