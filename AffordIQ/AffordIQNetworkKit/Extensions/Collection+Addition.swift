//
//  Collection+Addition.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension Dictionary where Key == String, Value == Any {
    var queryItems: [URLQueryItem] {
        self.map {
            if let string = $0.value as? String {
                return URLQueryItem(name: $0.key, value: string)
            } else if let integer = $0.value as? Int {
                return URLQueryItem(name: $0.key, value: String(integer))
            } else {
                return URLQueryItem(name: $0.key, value: $0.value as? String)
            }
        }
    }
}
