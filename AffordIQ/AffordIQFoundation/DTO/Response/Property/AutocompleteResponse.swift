//
//  AutocompleteResponse.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct AutocompleteResponse: Decodable, Equatable, Hashable {
    public var suggestions: [Suggestion]
}

public struct Suggestion: Decodable, Equatable, Hashable {
    public let identifier: String?
    public let value: String
    
    public init(value: String) {
        self.value = value
        identifier = nil
    }
}
