//
//  FeedbackServiceMock.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 20/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQNetworkKit
@testable import AffordIQUI
@testable import AffordIQFoundation

class FeedbackServiceMock: FeedbackSource {
    func submitFeedback(_ model: RMFeedback) async throws -> BaseResponse {
        if model.comment == "Success" {
            return BaseResponse(description: "", errors: [], message: "", statusCode: 200)
        } else {
            throw NetworkError.badID
        }
    }
}

extension FeedbackServiceMock: Equatable {
    static func == (lhs: FeedbackServiceMock, rhs: FeedbackServiceMock) -> Bool {
        lhs === rhs
    }
}
