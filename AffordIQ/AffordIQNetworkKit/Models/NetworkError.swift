//
//  NetworkError.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    /// The supplied URL was invalid.
    case badURLRequest
    case badID
    case serviceNotAvailable
    case emptyObject
    case decodeFailed(error: Error)
    case createURLFailed(reason: String)
    case responseFailed(reason: URLResponse)
    case emptyBody
    case unexpectedStatusCode(code: Int)
    /// The specified endpoint requires authentication and there is no logged in user.
    ///  - url: The full URL of the endpoint.
    case unauthorized
    /// The endpoint returned an empty HTTP response body.
    ///  - response: the HTTP response returned.
    case emptyResponseBody(response: HTTPURLResponse)
    /// An HTTP error code was returned by the API.
    ///  - url: The full URL of the endpoint.
    ///  - underlyingError: An NSError from the HTTP domain containing the error.
    case httpError(url: URL?, underlyingError: NSError)
    /// An unexpected non-HTTP response was received from the endpoint.
    ///  - response: The non-HTTP response received.
    case nonHTTPResponse(response: URLResponse?)
    
    var id: String {
        switch self {
        case .badURLRequest: return "badURLRequest"
        case .badID: return "badID"
        case .serviceNotAvailable: return "serviceNotAvailable"
        case .emptyObject: return "emptyObject"
        case .decodeFailed: return "decodeFailed"
        case .createURLFailed: return "createURLFailed"
        case .responseFailed: return "responseFailed"
        case .unexpectedStatusCode: return "unexpectedStatusCode"
        case .unauthorized: return "unauthorized"
        case .emptyResponseBody(response: let response):
            return "emptyResponseBody-\(response)"
        case let .httpError(url: url, underlyingError: underlyingError):
            return "httpError-\(String(describing: url))-\(underlyingError)"
        case .nonHTTPResponse(response: let response):
            return "nonHTTPResponse-\(String(describing: response))"
        case .emptyBody:
            return "emptyResponseBody"
        }
    }
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.id == rhs.id
    }
}
