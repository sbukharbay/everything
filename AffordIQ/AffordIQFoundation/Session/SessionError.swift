//
//  SessionError.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

/// An error recieved on authentication or logout.
public enum SessionError: Error {
    /// The authentication or logout operation was cancelled by the user.
    case cancelled
    /// The application can't connect to the authentication service.
    case cantConnect(error: Error)
    /// The offline session has expired - full authentication is required.
    case offlineSessionExpired
    /// An unknown error occurred.
    ///  - error: the underlying error.
    case other(error: Error)
}
