//
//  Application+Error.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 06/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum ApplicationError: Error {
    case selfNotDefined
}

extension ApplicationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .selfNotDefined:
            return NSLocalizedString("Object Self is not defined, try again", comment: "Object Self is not defined, try again. If it does not help, contact support team.")
        }
    }
}
