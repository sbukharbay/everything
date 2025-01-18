//
//  UserDetailsMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 20/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQFoundation

struct UserDetailsMock: UserDetails {
    var name: String
    var givenName: String
    var username: String
    var locale: String
    var familyName: String
    var email: String
    var externalUserId: String
    
    static func getMock() -> UserDetails {
        UserDetailsMock(name: "johnsmith@blackarrowgroup.com",
                        givenName: "John",
                        username: "johnsmith",
                        locale: "En",
                        familyName: "Smith",
                        email: "johnsmith@blackarrowgroup.com",
                        externalUserId: "auth0userID")
    }
}
