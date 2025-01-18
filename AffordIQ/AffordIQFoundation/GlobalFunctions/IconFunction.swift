//
//  IconFunction.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public func getIconName(_ categoryName: String) -> String {
    switch categoryName {
    case "Rent":
        return "house.circle"
    case "Banking":
        return "building.columns.fill"
    case "Debt":
        return "sterlingsign.circle"
    case "Entertainment":
        return "face.smiling"
    case "Health":
        return "cross.fill"
    case "Fitness":
        return "figure.walk"
    case "Household":
        return "house.fill"
    case "Insurance":
        return "checkmark.shield.fill"
    case "Investments":
        return "chart.bar.xaxis"
    case "Personal & Family":
        return "person.2.fill"
    case "Shopping":
        return "cart.fill"
    case "Travel":
        return "airplane"
    case "Vehicles":
        return "car.fill"
    case "Credit":
        return "sterlingsign.circle.fill"
    case "Business":
        return "building.2.fill"
    case "Miscellaneous":
        return "questionmark"
    default:
        return "house.circle"
    }
}
