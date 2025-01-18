//
//  UserDetails.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

/// The currently logged in user.
public protocol UserDetails {
    /// The user's full name.
    var name: String { get }
    /// The user's given name (forename).
    var givenName: String { get }
    /// The user's username (typically the same as their email address).
    var username: String { get }
    var locale: String { get }
    /// The user's family name (surname).
    var familyName: String { get }
    /// The user's email address.
    var email: String { get }
    /// The external user ID, used in calls to Black Arrow endpoints where the user must be identified.
    var externalUserId: String { get set }
}

public extension UserDetails {
    var fullName: String {
        givenName + " " + familyName
    }
}
