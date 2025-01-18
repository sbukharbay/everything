//
//  GoalsViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

class GoalsViewModel {
    @Published var error: Error?
    @Published var willUpdateBottom: Bool = false
    @Published var mortgageLimits: PropertyGoalAndMortgageLimitsResponse?
    var overlayData: [AffordabilityData] = []
    var mortgageDetails: MortgageDetails?
    
    private let affordabilitySource: AffordabilitySource
    private let userSession: SessionType
    
    var progressBarAmount: Float {
        (mortgageLimits?.mortgageLimits?.currentDeposit.amount?.floatValue ?? 0) / (mortgageLimits?.targetDeposit?.amount?.floatValue ?? 1)
    }
    
    init(
        affordabilitySource: AffordabilitySource = AffordabilityService(),
        userSession: SessionType = Auth0Session.shared
    ) {
        self.affordabilitySource = affordabilitySource
        self.userSession = userSession
        
        resume()
    }
    
    @MainActor
    func getMortgageAffordability() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let affordability = try await affordabilitySource.getGoalTrackingAndMortgageLimits(userID: userID)
            
            mortgageLimits = affordability
            let deposit = 1 - (affordability.depositGoal?.loanToValue ?? 0)
            getMortgageDetails(property: affordability, deposit: deposit.floatValue)
        } catch {
            self.error = error
        }
    }
    
    func resume() {
        Task {
            await getMortgageAffordability()
        }
    }
    
    func getMortgageDetails(property: PropertyGoalAndMortgageLimitsResponse, deposit: Float) {
        guard let userID = userSession.userID else { return }
        
        Task {
            do {
                let response = try await affordabilitySource.getMortgageDetails(
                    userID: userID,
                    depositAbsoluteValue: deposit.description,
                    propertyValue: property.propertyGoal?.propertyValue?.amount?.description ?? "0"
                )
                
                await MainActor.run {
                    mortgageDetails = response.mortgageDetails
                    setOverlayData()
                }
            } catch {
                self.error = error
            }
        }
    }
    
    func setOverlayData() {
        guard let details = mortgageDetails, let limits = mortgageLimits else { return }
        
        overlayData = [
            AffordabilityData(
                info: OverlayData(icon: "banknote", title: "Fee & Cost Estimations", value: limits.fees?.shortDescription ?? "N/A"),
                details: []),
            AffordabilityData(
                info: OverlayData(
                    icon: "mortgage", title: "Expected Mortgage", value: ""),
                details: [
                    OverlayData(icon: "mortgage", title: "Mortgage", value: details.mortgage.shortDescription),
                    OverlayData(icon: "sterlingsign.circle", title: "Repayments", value: details.repayment.shortDescription + "/m"),
                    OverlayData(icon: "interest_rate", title: "Interest Rate", value: String(format: "%.1f", details.interestRate * 100) + "%"),
                    OverlayData(icon: "clock.arrow.circlepath", title: "Mortgage Term", value: details.term.description)
                ])
        ]
        
        willUpdateBottom = true
    }
}
