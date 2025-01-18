//
//  AffordIQError.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 31/10/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum AffordIQError: Error {
    case openBankingAuthorisationNotComplete
    case invalidURL(url: String)
}
