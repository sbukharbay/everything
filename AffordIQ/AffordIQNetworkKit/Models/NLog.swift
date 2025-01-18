//
//  NetworkLog.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

internal final class NLog {
    static func log(request: URLRequest, response: URLResponse, data: Data) {
        log(request: request)
        log(response: response as? HTTPURLResponse)
        print("Response Data:")
        log(data: data)
        logDivider()
    }
    
    static func log(request: URLRequest) {
        print("(REQUEST)\n» \(request.httpMethod ?? "") \(request)\n")
        logHeaders(title: "Request", headers: request.allHTTPHeaderFields)
        print("Body:")
        log(data: request.httpBody)
        print("")
    }
    
    static func log(response: HTTPURLResponse?) {
        guard let response = response else {
            return
        }

        print("(RESPONSE)\n» [\(response.statusCode)] \(response.url?.absoluteString ?? "") \n")
        logHeaders(title: "Response", headers: response.allHeaderFields)
    }
    
    static func log(data: Data?) {
        guard let data = data else { return }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            if let prettyPrintedString = String(data: prettyData, encoding: .utf8) {
                print(prettyPrintedString)
            }
        } catch {
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                print(string)
            }
        }
    }
    
    private static func logDivider(header: String? = nil) {
        print("\n« ------------- « ----------------- « \(header ?? "o") » ------------- » ----------------- »\n")
    }
    
    private static func logHeaders(title: String = "", headers: [AnyHashable: Any]?) {
        guard let headers = headers else { return }
        
        print("\(title) Headers: [")
        for (key, value) in headers {
            print("  \(key) : \(value)")
        }
        print("]\n")
    }
}
