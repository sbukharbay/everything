//
//  UserRegistrationData.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct UserRegistrationData: Response {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public var dateOfBirth: String
    public var firstName: String
    public var lastName: String
    public var mobilePhone: String
    public var username: String
    
    public init(dateOfBirth: String, firstName: String, lastName: String, mobilePhone: String, username: String) {
        self.dateOfBirth = dateOfBirth
        self.firstName = firstName
        self.lastName = lastName
        self.mobilePhone = mobilePhone
        self.username = username
        statusCode = 200
        message = ""
        errors = []
        description = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case dateOfBirth = "date_of_birth"
        case firstName = "first_name"
        case lastName = "last_name"
        case mobilePhone = "mobile_phone"
        case username
    }
}
