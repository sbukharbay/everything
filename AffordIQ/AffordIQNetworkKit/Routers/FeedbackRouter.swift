//
//  FeedbackRouter.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public enum FeedbackRouter: RequestConvertible {
    case submitFeedback(model: RMFeedback)
    
    public var path: String {
        switch self {
        case .submitFeedback:
            return "/api/feedback"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .submitFeedback:
            return .post
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .submitFeedback(let model):
            return model.toDictionary
        }
    }
}
