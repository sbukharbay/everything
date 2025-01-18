//
//  OnboardingSource.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 21/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol OnboardingSource {
    func onboardingComplete(_ userID: String) async throws -> BaseResponse
}

public final class OnboardingService: AdaptableNetwork<OnboardingRouter>, OnboardingSource {
    public func onboardingComplete(_ userID: String) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .onboardingComplete(userID: userID))
    }
}
