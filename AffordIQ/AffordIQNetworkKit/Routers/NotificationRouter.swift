//
//  NotificationRouter.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 24/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum NotificationRouter: RequestConvertible {
    case registerDevice(userID: String, model: RMRegisterDevice)
    
    public var path: String {
        switch self {
        case .registerDevice(let userID, _):
            return "/api/notification/\(userID)/register-device"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .registerDevice:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .registerDevice(_, let model):
            return model.toDictionary
        }
    }
}
