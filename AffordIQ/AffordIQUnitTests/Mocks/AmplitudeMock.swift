//
//  AmplitudeMock.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 29/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Amplitude

class AmplitudeMock: AmplitudeProtocol {
    var isLogged = false
    
    func logEvent(key: String) {
        isLogged = true
    }
}
