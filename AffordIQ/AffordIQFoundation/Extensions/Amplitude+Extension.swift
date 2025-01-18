//
//  Amplitude+Extension.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 29/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Amplitude

public protocol AmplitudeProtocol {
    func logEvent(key: String)
}

extension Amplitude: AmplitudeProtocol {
    public func logEvent(key: String) {
        Amplitude.instance().logEvent(key)
    }
}
