//
//  OpenBankingServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 29.09.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class OpenBankingServiceMock: OpenBankingSource {
    func checkAuthStatus(of userID: String) async throws -> AffordIQFoundation.OpenBankingAuthoriseStatus {
        throw NetworkError.badURLRequest
    }
    
    var willThrowError = false
    
    func getProviders() async throws -> ProvidersResponse {
        if !willThrowError {
            return [Provider(displayName: "", logoURL: "", providerId: "", scopes: [""], country: "")]
        } else {
            throw NetworkError.badURLRequest
        }
    }
    
    func authoriseCode(body: RMAuthoriseBank) async throws -> BaseResponse {
        if body.code == "error" {
            throw NetworkError.badURLRequest
        } else {
            return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
        }
    }
    
    func authorise(userID: String, providerID: String) async throws -> BaseResponse {
        throw NetworkError.badID
    }
    
    func reconsent(userID: String, providers: ReconsentRequestModel) async throws -> OpenBankingReconsent {
        if userID == "error" {
            throw NetworkError.badURLRequest
        } else if userID == "trueLayer" {
            return OpenBankingReconsent(statusCode: 200, trueLayerResponse: nil)
        } else {
            let trueLayerResponse = [TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: "")),
                                     TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: "")),
                                     TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: "")),
                                     TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: "")),
                                     TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .none, refreshToken: "", userInputLink: ""))]
            return OpenBankingReconsent(statusCode: 200, trueLayerResponse: trueLayerResponse)
        }
    }
}
