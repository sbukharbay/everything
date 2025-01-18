//
//  LoginServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 28/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQNetworkKit
@testable import AffordIQFoundation

class LoginServiceMock: LoginSource {
    var getTokenCalled = false
    
    func fetchToken(_ model: RMFetchToken) async throws -> FetchTokenResponse {
        getTokenCalled = true
        if model.clientId == "clientID" {
            return FetchTokenResponse(accessToken: "clientID", expiresIn: 5000, tokenType: "")
        } else {
            throw NetworkError.badID
        }
    }
}
