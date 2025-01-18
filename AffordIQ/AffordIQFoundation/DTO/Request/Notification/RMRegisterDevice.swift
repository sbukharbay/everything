//
//  RMRegisterDevice.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 24/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMRegisterDevice: Codable {
    public let deviceID: String
    public let token: String
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case token
    }
    
    public init(deviceID: String, token: String) {
        self.deviceID = deviceID
        self.token = token
    }
}
