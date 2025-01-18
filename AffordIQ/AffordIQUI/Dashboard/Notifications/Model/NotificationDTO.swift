//
//  NotificationDTO.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct NotificationDTO: Codable {
    public var title: String
    public var description: String
    public var date: Date
    public var userID: String? = ""
}
