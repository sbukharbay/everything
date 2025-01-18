//
//  FeedbackSource.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation

public protocol FeedbackSource {
    @discardableResult
    func submitFeedback(_ model: RMFeedback) async throws -> BaseResponse
}

public final class FeedbackService: AdaptableNetwork<FeedbackRouter>, FeedbackSource {
    public func submitFeedback(_ model: RMFeedback) async throws -> BaseResponse {
        try await request(BaseResponse.self, from: .submitFeedback(model: model))
    }
}
