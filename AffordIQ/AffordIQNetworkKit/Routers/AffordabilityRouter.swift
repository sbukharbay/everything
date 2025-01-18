//
//  AffordabilityRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 17/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum AffordabilityRouter: RequestConvertible {
    case getMortgageDetails(userID: String, depositAbsoluteValue: String, propertyValue: String)
    case getGoalTrackingAndMortgageLimits(userID: String)
    case getAffordabilityCalculations(userID: String, model: RMAffordabilityCalculations?)
    case getAffordabilityStatus(userID: String)
    case getAffordabilityPreview(userID: String)
    case getIncomeStatus(userID: String)
    case setIncomeStatus(userID: String, model: RMIncomeConfirmation)
    
    public var path: String {
        switch self {
        case let .getMortgageDetails(userID, depositAbsoluteValue, propertyValue):
            return "/api/affordability/\(userID)/mortgage-details/\(depositAbsoluteValue)/\(propertyValue)"
        case .getGoalTrackingAndMortgageLimits(let userID):
            return "/api/affordability/\(userID)/goal-tracking-and-mortgage-limits"
        case .getAffordabilityCalculations(let userID, _):
            return "/api/affordability/\(userID)/affordability-calculations"
        case .getAffordabilityStatus(let userID):
            return "/api/affordability/status/\(userID)"
        case .getAffordabilityPreview(let userID):
            return "/api/affordability/\(userID)/affordability-preview"
        case .getIncomeStatus(let userID), .setIncomeStatus(let userID, _):
            return "/api/affordability/\(userID)/income-status"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getMortgageDetails,
             .getGoalTrackingAndMortgageLimits,
             .getAffordabilityCalculations,
             .getAffordabilityStatus,
             .getAffordabilityPreview,
             .getIncomeStatus:
            return .get
        case .setIncomeStatus:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .getAffordabilityCalculations(_, let model):
            return model.toDictionary
        case .setIncomeStatus(_, let model):
            return model.toDictionary
        default: return nil
        }
    }
}
