//
//  RMCreateUser.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMCreateUser: Encodable {
    public let firstName: String
    public let lastName: String
    public let mobilePhone: String
    public let dateOfBirth: String
    public let password: String
    public let username: String
    
    public init(firstName: String, lastName: String, mobilePhone: String, dateOfBirth: String, password: String, username: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.mobilePhone = mobilePhone
        self.dateOfBirth = dateOfBirth
        self.password = password
        self.username = username
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case mobilePhone = "mobile_phone"
        case dateOfBirth = "date_of_birth"
        case password
        case username
    }
}
