//
//  SetDepositViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 14/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import Foundation
import AffordIQAuth0
import AffordIQNetworkKit
import Combine

class SetDepositViewModel {
    @Published var error: Error?
    @Published var isLoading: Bool
    var updateSubject = PassthroughSubject<Bool, Never>()
    var setSliderSubject = PassthroughSubject<Bool, Never>()
    var operationCompleteSubject = PassthroughSubject<Bool, Never>()
    
    var affordabilityData: [AffordabilityPreviewModel]?
    var currentDeposit: MonetaryAmount?
    var loanToValueData: Float
    var isDashboard: Bool
    
    private var userSession: SessionType
    private var goalSource: GoalSource
    private var affordabilitySource: AffordabilitySource

    init(goalSource: GoalSource = GoalService(),
         userSession: SessionType = Auth0Session.shared,
         affordabilitySource: AffordabilitySource = AffordabilityService(),
         isDashboard: Bool) {
        self.isDashboard = isDashboard
        self.goalSource = goalSource
        self.userSession = userSession
        self.affordabilitySource = affordabilitySource
        loanToValueData = 10
        isLoading = true
        
        Task {
            isLoading = true
            do {
                try await getAffordabilityPreview()
                try await getDepositGoal()
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }

    @MainActor
    func getAffordabilityPreview() async throws {
        guard let userID = userSession.userID else { throw NetworkError.unauthorized }
        let response = try await affordabilitySource.getAffordabilityPreview(userID: userID)
        
        affordabilityData = response.affordabilityPreview
        currentDeposit = response.currentDeposit
        
        updateSubject.send(true)
    }
    
    @MainActor
    func getDepositGoal() async throws {
        guard let userID = userSession.userID else { throw NetworkError.unauthorized }
        let response = try await goalSource.getAllGoals(userID: userID)
        
        if let deposit = response.depositGoal?.loanToValue?.floatValue {
            loanToValueData = 100 - (deposit * 100)
        } else {
            loanToValueData = 10
        }
        
        setSliderSubject.send(true)
    }

    @MainActor
    func setDepositGoal() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let model = RMDepositGoal(loanToValue: (100 - loanToValueData) / 100)
            
            try await goalSource.setDepositGoal(userID: userID, model: model)
            operationCompleteSubject.send(true)
        } catch {
            self.error = error
        }
    }
}
