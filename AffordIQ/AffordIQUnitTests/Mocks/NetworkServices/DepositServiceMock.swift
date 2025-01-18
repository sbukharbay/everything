//
//  DepositServiceMock.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 14.12.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class DepositServiceMock: DepositSource {
    var deletedExternalCapital = false
    
    func confirmSavings(userID: String) async throws -> AffordIQFoundation.BaseResponse {
        return BaseResponse(description: nil, errors: nil, message: nil, statusCode: 200)
    }
    
    func deleteExternalCapital(userID: String) async throws -> AffordIQFoundation.BaseResponse {
        deletedExternalCapital = true
        return BaseResponse(description: nil, errors: nil, message: nil, statusCode: 200)
    }
    
    func getExternalCapital(userID: String) async throws -> AffordIQFoundation.ExternalCapitalResponse {
        throw NetworkError.badID
    }
    
    func createExternalCapital(userID: String, model: AffordIQFoundation.RMExternalCapital) async throws -> AffordIQFoundation.BaseResponse {
        return BaseResponse(description: nil, errors: nil, message: nil, statusCode: 200)
    }
    
    func updateExternalCapital(userID: String, model: AffordIQFoundation.RMExternalCapital) async throws -> AffordIQFoundation.BaseResponse {
        return BaseResponse(description: nil, errors: nil, message: nil, statusCode: 200)
    }
    
    func getBalance(userID: String) async throws -> AffordIQFoundation.DepositBalanceResponse {
        throw NetworkError.badID
    }
    
    func updateAccounts(model: AffordIQFoundation.RMAccountsUsedForDeposit) async throws -> AffordIQFoundation.BaseResponse {
        return BaseResponse(description: nil, errors: nil, message: nil, statusCode: 200)
    }
}
