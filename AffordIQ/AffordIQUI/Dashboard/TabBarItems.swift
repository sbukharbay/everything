//
//  TabBarItems.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 10/05/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

extension UITabBarItem {
    static var affordability: UITabBarItem {
        let tabBarItem = UITabBarItem(
            title: NSLocalizedString("Affordability",
                                     bundle: uiBundle,
                                     comment: "Affordability"),
            image: UIImage(named: "nav_affordability",
                           in: uiBundle, with: nil),
            selectedImage: UIImage(named: "nav_affordability", in: uiBundle, with: nil)
        )
        tabBarItem.accessibilityIdentifier = "Dashboard.Affordability"
        return tabBarItem
    }

    static var goals: UITabBarItem {
        let tabBarItem = UITabBarItem(title: NSLocalizedString("Goals", bundle: uiBundle, comment: "Goals"), image: UIImage(named: "nav_goals", in: uiBundle, with: nil), selectedImage: UIImage(named: "nav_goals", in: uiBundle, with: nil))
        tabBarItem.accessibilityIdentifier = "Dashboard.Goals"
        return tabBarItem
    }

    static var budget: UITabBarItem {
        let tabBarItem = UITabBarItem(title: NSLocalizedString("Budget", bundle: uiBundle, comment: "Budget"), image: UIImage(systemName: "sterlingsign.circle.fill"), selectedImage: UIImage(systemName: "sterlingsign.circle.fill"))
        tabBarItem.accessibilityIdentifier = "Dashboard.Budget"
        return tabBarItem
    }

    static var home: UITabBarItem {
        let tabBarItem = UITabBarItem(title: NSLocalizedString("Home", bundle: uiBundle, comment: "Home"), image: UIImage(named: "nav_home", in: uiBundle, with: nil), selectedImage: UIImage(named: "nav_home", in: uiBundle, with: nil))
        tabBarItem.accessibilityIdentifier = "Dashboard.Home"
        return tabBarItem
    }
}
