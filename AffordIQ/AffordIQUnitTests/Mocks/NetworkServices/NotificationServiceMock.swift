//
//  NotificationServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 01/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

class NotificationServiceMock: NotificationSource {
    var didDeviceRegister = false
    
    func registerDevice(userID: String, model: RMRegisterDevice) async throws -> BaseResponse {
        if userID == "error" {
            throw NetworkError.unauthorized
        } else {
            didDeviceRegister = true
            return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
        }
    }
}
