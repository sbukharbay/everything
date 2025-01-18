//
//  URLComponents+Extensions.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

extension URLComponents {
    init(uri: String?, port portValue: String? = nil) {
        self.init()
        
        guard let uri = uri else {
            return
        }
        
        scheme = "https"
        host = uri.components(separatedBy: "/").first
        path = String(uri.dropFirst(host?.count ?? 0))
        
        if let portValue = portValue?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
           !portValue.isEmpty,
           let portNumber = Int(portValue) {
            port = portNumber
        }
    }
}
