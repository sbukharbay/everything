//
//  Response.swift
//  AffordIQNetworkKit
//
//  Created by Asilbek Djamaldinov on 23/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

/// A generic response from a Black Arrow API endpoint.
public protocol Response: Decodable {
    /// A human-readable description of the response.
    var description: String? { get }
    /// An optional array containing error messages from the endpoint.
    var errors: [String]? { get }
    /// An optional message from the endpoint.
    var message: String? { get }
    /// The HTTP status code of the response.
    var statusCode: Int { get }
}
