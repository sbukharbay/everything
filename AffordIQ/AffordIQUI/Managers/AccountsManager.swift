//
//  AccountsManager.swift
//  AffordIQUI
//
//  Created by  Sultangazy Bukharbay on 11/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQNetworkKit
import AffordIQFoundation

final class AccountsManager {
    static let shared = AccountsManager()
    
    var categories: [SpendingCategoriesModel] = []
    
    private let spendingSource: SpendingSource = SpendingService()
    
    var isOnboardingCategorisationDone: Bool {
        get {
            GeneralPreferences.shared.isOnboardingCategorisationDone
        } set {
            GeneralPreferences.shared.isOnboardingCategorisationDone = newValue
        }
    }
    
    private init() { }
    
    func cleanDatabase() {
        isOnboardingCategorisationDone = false
    }
    
    func getSpendingCategories() async throws {
        let response = try await spendingSource.getSpendingCategories()
        categories = response.spendingCategories
        
        categories.enumerated().forEach { index, item in
            categories[index].childCategory.append(ChildCategoriesModel(id: item.categoryId, name: "General"))
        }
    }
}
