//
//  NetworkStorageKey.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

internal enum NetworkStorageKey: String {
    case authData = "@storage.authentication-data"

    var key: String { self.rawValue }
}

internal extension UserDefaults {
    func string(forKey key: NetworkStorageKey) -> String? {
        string(forKey: key.rawValue)
    }
    
    func integer(forKey key: NetworkStorageKey) -> Int {
        integer(forKey: key.rawValue)
    }
    
    func object(forKey key: NetworkStorageKey) -> Any? {
        object(forKey: key.rawValue)
    }
    
    func bool(forKey key: NetworkStorageKey) -> Bool {
        bool(forKey: key.rawValue)
    }
    
    func value(forKey key: NetworkStorageKey) -> Any? {
        value(forKey: key.rawValue)
    }
    
    func data(forKey key: NetworkStorageKey) -> Data? {
        data(forKey: key.rawValue)
    }
}

internal extension UserDefaults {
    func set(_ value: Any?, forKey key: NetworkStorageKey) {
        set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Int, forKey key: NetworkStorageKey) {
        set(value, forKey: key.rawValue)
    }
    
    func set(_ value: Bool, forKey key: NetworkStorageKey) {
        set(value, forKey: key.rawValue)
    }
}
