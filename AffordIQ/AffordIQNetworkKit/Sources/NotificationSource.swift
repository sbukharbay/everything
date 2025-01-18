//
//  NotificationSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 24/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol NotificationSource {
    @discardableResult
    func registerDevice(userID: String, model: RMRegisterDevice) async throws -> BaseResponse
}

public final class NotificationService: AdaptableNetwork<NotificationRouter>, NotificationSource {
    public func registerDevice(userID: String, model: RMRegisterDevice) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .registerDevice(userID: userID, model: model))
    }
}
