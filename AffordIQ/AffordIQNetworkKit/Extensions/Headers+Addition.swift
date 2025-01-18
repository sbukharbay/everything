//
//  Headers+Addition.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension Headers {
    static func defaultHeaders(token: String?) -> Headers {
        var headers: Headers = [:]
        headers["Content-Type"] = "application/json; charset=utf-8"
        headers["Accept"] = "application/json; charset=utf-8"
        
        if let token {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
}
