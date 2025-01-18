//
//  NetworkManager.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Combine
import AffordIQFoundation
import Amplitude

public protocol NetworkManager {
    associatedtype Router: RequestConvertible
    
    var session: URLSession { get }
}

extension NetworkManager {
    public func request<T: Decodable>(_ type: T.Type, from router: Router) async throws -> T {
        guard let request = try await router.asURLRequest() else {
            throw NetworkError.badURLRequest
        }
        
        return try await sendRequest(T.self, request: request)
    }
    
    public func queryRequest<T: Decodable>(_ type: T.Type, from router: Router) async throws -> T {
        guard let request = try await router.asURLRequestFromQueryParams() else {
            throw NetworkError.badURLRequest
        }
        
        return try await sendRequest(T.self, request: request)
    }
    
    private func sendRequest<T: Decodable>(_ type: T.Type, request: URLRequest) async throws -> T {
        // Request data.
        let (data, response) = try await session.data(for: request)
        // Print on console.
        #if DEBUG || DEMO
        NLog.log(request: request, response: response, data: data)
        #endif
        // Check response.
        let checkedData = try await monitor(data: data, response: response)
        // Decode data.
        do {
            let decoder = JSONDecoder.affordIQDecoder()
            return try decoder.decode(T.self, from: checkedData)
        } catch let error {
            Amplitude.instance().logEvent("SERVER_ERROR", withEventProperties: ["Description": "Failed to decode the response data.", "Error": error.localizedDescription, "Endpoint": request.url ?? "URL"])
            guard let response = response as? HTTPURLResponse else {
                throw NetworkError.responseFailed(reason: response)
            }
            if response.statusCode == 204 {
                throw NetworkError.emptyBody
            } else {
                throw NetworkError.decodeFailed(error: error)
            }
        }
    }
    
    private func monitor(data: Data, response: URLResponse) async throws -> Data {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkError.responseFailed(reason: response)
        }
        
        try isValidCode(response, data)
        return data
    }
    
    private func isValidCode(_ response: HTTPURLResponse, _ data: Data) throws {
        guard response.statusCode >= 200 && response.statusCode < 300 else {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject?] {
                    var eventProperties = json
                    eventProperties["Endpoint"] = response.url as AnyObject?
                    
                    eventProperties.forEach {
                        if $0.value == nil {
                            eventProperties[$0.key] = "null" as AnyObject
                        }
                    }
                    
                    Amplitude.instance().logEvent("SERVER_ERROR", withEventProperties: eventProperties as [AnyHashable: Any])
                }
            } catch {
                Amplitude.instance().logEvent("SERVER_ERROR", withEventProperties: ["Description": "Request is failed, but the error message couldn't be extracted from the response", "Endpoint": response.url ?? "URL"])
            }
            
            switch response.statusCode {
            case 401: throw NetworkError.unauthorized
            default: throw NetworkError.unexpectedStatusCode(code: response.statusCode)
            }
        }
    }
}
