//
//  URLRequest+HTTPMethod.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension URLRequest {
    var method: HTTPMethod? {
        get {
            if let httpMethod = httpMethod {
                return HTTPMethod(rawValue: httpMethod)
            } else {
                return nil
            }
        } set(newMethod) {
            httpMethod = newMethod?.rawValue
        }
    }
}
