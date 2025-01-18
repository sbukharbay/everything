//
//  MorgageAffordabilityService.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 06/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQAPI

public protocol MorgageAffordabilitySource {
    func getGoalTrackingAndMorgageLimit(_ userID: String) async throws -> PropertyGoalAndMortgageLimitsResponse
}

public final class MorgageAffordabilityService: AdaptableNetwork<MorgageAffordabilityRouter>, MorgageAffordabilitySource {
    public func getGoalTrackingAndMorgageLimit(_ userID: String) async throws -> PropertyGoalAndMortgageLimitsResponse {
        try await request(PropertyGoalAndMortgageLimitsResponse.self, from: .goalTrackingAndMorgageLimit(userID: userID))
    }
}
