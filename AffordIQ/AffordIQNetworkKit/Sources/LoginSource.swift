//
//  LoginSource.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol LoginSource {
    func fetchToken(_ model: RMFetchToken) async throws -> FetchTokenResponse
}

public final class LoginService: AdaptableNetwork<LoginRouter>, LoginSource {
    public func fetchToken(_ model: RMFetchToken) async throws -> FetchTokenResponse {
        try await request(FetchTokenResponse.self, from: .fetchToken(model: model))
    }
}
