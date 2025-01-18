//
//  RMPatchUser.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMPatchUser: Encodable {
    public var dateOfBirth: String?
    public var firstName: String?
    public var lastName: String?
    public var mobilePhone: String?
    public var password: [String]?
    public var username: String?
    
    public init(dateOfBirth: String? = nil, firstName: String? = nil, lastName: String? = nil, mobilePhone: String? = nil, password: [String]? = nil, username: String? = nil) {
        self.dateOfBirth = dateOfBirth
        self.firstName = firstName
        self.lastName = lastName
        self.mobilePhone = mobilePhone
        self.password = password
        self.username = username
    }

    enum CodingKeys: String, CodingKey {
        case dateOfBirth = "date_of_birth"
        case firstName = "first_name"
        case lastName = "last_name"
        case mobilePhone = "mobile_phone"
        case password
        case username
    }
}
