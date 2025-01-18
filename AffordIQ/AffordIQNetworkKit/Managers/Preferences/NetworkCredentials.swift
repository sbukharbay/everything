//
//  NetworkCredentials.swift
//  AffordIQAPI
//
//  Created by Asilbek Djamaldinov on 14/12/2022.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public final class NetworkCredentials {
    public static let shared = NetworkCredentials()
    private let database: UserDefaults
    
    public init(_ database: UserDefaults = UserDefaults.standard) {
        self.database = database
    }
}
