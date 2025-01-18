//
//  GoalRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 19/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum GoalRouter: RequestConvertible {
    case getAllGoals(userID: String)
    case savingsGoal(userID: String, model: RMSavingGoalSet)
    case setSpendingGoal(userID: String, model: [RMSpendingTarget])
    case setDepositGoal(userID: String, model: RMDepositGoal)
    case setPropertyGoal(userID: String, model: RMPropertyGoal)
    
    public var path: String {
        switch self {
        case .getAllGoals(let userID):
            return "/api/goals/\(userID)/all"
        case .savingsGoal(let userID, _):
            return "/api/goals/\(userID)/savings"
        case .setSpendingGoal(let userID, _):
            return "/api/goals/\(userID)/spending-category"
        case .setDepositGoal(let userID, _):
            return "/api/goals/\(userID)/deposit"
        case let .setPropertyGoal(userID, _):
            return "/api/goals/\(userID)/property"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getAllGoals:
            return .get
        case .savingsGoal,
             .setSpendingGoal,
             .setDepositGoal,
             .setPropertyGoal:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .getAllGoals:
            return nil
        case .savingsGoal(_, let model):
            return model.toDictionary
        case .setDepositGoal(_, let model):
            return model.toDictionary
        default: return nil
        }
    }
    
    public var body: Body? {
        switch self {
        case .setSpendingGoal(_, let model):
            return model.asJson
        case .setPropertyGoal(_, let model):
            return model.asJson
        default: return nil
        }
    }
}
