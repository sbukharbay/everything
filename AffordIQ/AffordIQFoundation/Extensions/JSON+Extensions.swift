//
//  JSON+Extensions.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension JSONEncoder {
    static func affordIQEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.dataEncodingStrategy = .base64
        return encoder
    }
}

public extension JSONDecoder {
    static func affordIQDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        decoder.dataDecodingStrategy = .base64
        return decoder
    }
}
