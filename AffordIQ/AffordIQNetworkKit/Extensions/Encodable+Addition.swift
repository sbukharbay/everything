//
//  Encodable+Additions.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public extension Encodable {
    var toDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        
        return jsonObject.flatMap { $0 as? [String: Any] }
    }
    
    var asJson: Any? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        
        return jsonObject
    }
    
    var toLoginDictionary: [String: Any]? {
        guard let data = try? JSONEncoder.affordIQEncoder().encode(self) else {
            return nil
        }
        
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
        
        return jsonObject.flatMap { $0 as? [String: Any] }
    }
}
