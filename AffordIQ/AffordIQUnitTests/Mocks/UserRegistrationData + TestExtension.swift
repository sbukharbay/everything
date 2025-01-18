//
//  UserRegistrationData + TestExtension.swift
//  AffordIQ
//
//  Created by Asilbek Djamaldinov on 13/07/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

extension UserRegistrationData {
    static func getMock() -> Self {
        UserRegistrationData(dateOfBirth: "1 January 1990", firstName: "John", lastName: "Doe", mobilePhone: "+440000000000", username: "username@email.com")
    }
}
