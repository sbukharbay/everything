//
//  RMFeedback.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 16/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMFeedback: Codable, Equatable {
    public let name: String
    public let email: String
    public let comment: String
    public let screenName: String
    public let reason: String
    public let appVersion: String
    public let osType: String
    
    public init(name: String, email: String, comment: String, screenName: String, reason: String, appVersion: String, osType: String = "IOS") {
        self.name = name
        self.email = email
        self.comment = comment
        self.screenName = screenName
        self.reason = reason
        self.appVersion = appVersion
        self.osType = osType
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case comment
        case screenName = "feedback_screen_name"
        case reason = "feedback_reason"
        case appVersion = "app_version"
        case osType = "os_type"
    }
}
