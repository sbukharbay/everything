//
//  UserRouter.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 27.04.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum UserRouter: RequestConvertible {
    case getUserDetails(userID: String)
    case getUserStatus(userID: String)
    case completeOnboarding(userID: String)
    case getUserID(externalID: String)
    case getAuth0User(userID: String)
    case checkIfUsernameExists(username: String)
    case setUserAgree(model: RMTerms)
    case updateUser(userID: String, model: RMPatchUser)
    case createUser(model: RMCreateUser)
    case deleteUser(userID: String)
    
    public var path: String {
        switch self {
        case .getUserDetails(let userID):
            return "/api/users/details/\(userID)"
        case .getUserStatus(let userID):
            return "/api/users/status/\(userID)"
        case .completeOnboarding(let userID):
            return "/api/users/completed-onboarding/\(userID)"
        case .getUserID(let externalID):
            return "/api/users/get/\(externalID)"
        case .getAuth0User(let userID):
            return "/api/users/auth0User/\(userID)"
        case .checkIfUsernameExists(let username):
            return "/api/users/exists/\(username)/"
        case .setUserAgree:
            return "/api/users/tsandcs"
        case .updateUser(let userID, _):
            return "/api/users/\(userID)"
        case .createUser:
            return "/api/users/create"
        case .deleteUser(let userID):
            return "/api/users/\(userID)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .getUserDetails,
             .getUserStatus,
             .getUserID,
             .getAuth0User,
             .checkIfUsernameExists:
            return .get
        case .completeOnboarding,
             .setUserAgree,
             .createUser:
            return .post
        case .updateUser:
            return .patch
        case .deleteUser:
            return .delete
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .updateUser(_, let model):
            return model.toDictionary
        case .setUserAgree(let model):
            return model.toDictionary
        case .createUser(let model):
            return model.toDictionary
        default:
            return nil
        }
    }
    
    public var isAuthorized: Bool {
        switch self {
        case .getUserDetails,
             .getUserStatus,
             .completeOnboarding,
             .getUserID,
             .getAuth0User,
             .updateUser,
             .setUserAgree,
             .deleteUser:
            return true
        case .checkIfUsernameExists,
             .createUser:
            return false
        }
    }
}
