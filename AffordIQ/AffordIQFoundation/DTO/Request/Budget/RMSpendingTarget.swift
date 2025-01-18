//
//  RMSpendingTarget.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct RMSpendingTarget: Codable {
    public var categoryId: Int
    public var categoryName: String
    public var id: Int?
    public var monthlySpendingTarget: MonetaryAmount
    public var parentGoalId: Int?
    public var state: String?
    
    public init(categoryId: Int, categoryName: String, id: Int?, monthlySpendingTarget: MonetaryAmount) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.id = id
        self.monthlySpendingTarget = monthlySpendingTarget
    }
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
        case id
        case monthlySpendingTarget = "monthly_spending_target"
        case parentGoalId = "parent_goal_id"
        case state
    }
}
