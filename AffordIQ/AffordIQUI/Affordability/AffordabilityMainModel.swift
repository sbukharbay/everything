//
//  AffordabilityMainModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

struct OverlayData {
    var icon: String
    var title: String
    var value: String
}

struct AffordabilityData {
    var info: OverlayData
    var details: [OverlayData]
}

public enum AffordabilityMainViewType: Equatable {
    case setGoal
    case dashboard
    case filter(search: ChosenPropertyParameters, mortgageLimits: MortgageLimits?)
    case tabbar
    
    public static func == (lhs: AffordabilityMainViewType, rhs: AffordabilityMainViewType) -> Bool {
        switch (lhs, rhs) {
        case (.setGoal, .setGoal):
            return true
        case (.dashboard, .dashboard):
            return true
        case (.filter, .filter):
            return true
        case (.tabbar, .tabbar):
            return true
        default: return false
        }
    }
}
