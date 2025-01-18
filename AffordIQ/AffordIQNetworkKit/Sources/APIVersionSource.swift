//
//  APIVersionSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 03/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol APIVersionSource {
    func getApiVersionNumber() async throws -> ApiVersionResponse
}

public final class APIVersionService: AdaptableNetwork<APIVersionRouter>, APIVersionSource {
    public func getApiVersionNumber() async throws -> ApiVersionResponse {
        try await request(ApiVersionResponse.self, from: .getApiVersionNumber)
    }
}
