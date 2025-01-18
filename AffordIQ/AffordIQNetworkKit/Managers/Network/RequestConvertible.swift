//
//  RequestConvertible.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Combine
import AffordIQFoundation

public typealias Parameters = [String: Any]
public typealias Headers = [String: String]
public typealias Body = Any

public protocol RequestConvertible {
    var environment: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var isAuthorized: Bool { get }
    var body: Body? { get }
    
    func headers(token: String?) -> Headers?
    func asURLRequest() async throws -> URLRequest?
}

extension RequestConvertible {
    public var environment: String {
        return Environment.shared.baseURL.absoluteString
    }
    
    public var isAuthorized: Bool {
        return true
    }
    
    public func headers(token: String?) -> Headers? {
        return .defaultHeaders(token: token)
    }
    
    public var parameters: Parameters? {
        return nil
    }
    
    public var body: Body? {
        return nil
    }
    
    public func asURL() throws -> URL {
        let endPointString = makeEndPoint()
        
        if let url = URL(string: endPointString) {
            return url
        } else {
            throw NetworkError.createURLFailed(reason: "Couldn't create URL from \(endPointString)")
        }
    }
    
    public func asQueryURL() throws -> URL {
        let endPointString = makeEndPoint()
        var component = URLComponents(string: endPointString)
        component?.queryItems = parameters?.queryItems
        
        if let url = component?.url {
            return url
        } else {
            throw NetworkError.createURLFailed(reason: "Couldn't create URL from \(endPointString)")
        }
    }
    
    public func asURLRequest() async throws -> URLRequest? {
        return try await makeURLRequest(from: try asURL())
    }
    
    public func asURLRequestFromQueryParams() async throws -> URLRequest? {
        return try await makeURLRequest(from: try asQueryURL(), isQuery: true)
    }
    
    private func makeEndPoint() -> String {
        return environment + path
    }
    
    private func makeURLRequest(from url: URL, isQuery: Bool = false) async throws -> URLRequest? {
        var token: String?
        
        var urlRequest = URLRequest(url: url)
        urlRequest.method = method
        
        if isAuthorized {
            do {
                let authData = try await AuthManager.shared.validToken()
                token = authData.accessToken
            } catch {
                print(error)
                throw error
            }
        }
        
        urlRequest.allHTTPHeaderFields = headers(token: token)
        
        if let parameters, !isQuery {
            urlRequest.httpBody = try JSONSerialization.data(
                withJSONObject: parameters,
                options: .prettyPrinted
            )
        } else if let body {
            urlRequest.httpBody = try JSONSerialization.data(
                withJSONObject: body,
                options: .prettyPrinted
            )
        }
        
        return urlRequest
    }
}
