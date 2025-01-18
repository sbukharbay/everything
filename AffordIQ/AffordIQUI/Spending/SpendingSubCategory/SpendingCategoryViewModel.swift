//
//  SpendingSubCategoryViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 27/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import AffordIQNetworkKit
import Combine

class SpendingCategoryViewModel {
    @Published var error: Error?
    var updateSubject = PassthroughSubject<Bool, Never>()
    var categories: [SpendingCategoriesModel]
    var isCategory = true
    var selectedCategory: SpendingCategoriesModel?
    var selectedSubCategory: ChildCategoriesModel?
    var completion: ((ChildCategoriesModel) -> Void)?
    
    private let spendingSource: SpendingSource

    init(spendingSource: SpendingSource = SpendingService(),
         completion: ((ChildCategoriesModel) -> Void)? = nil) {
        self.spendingSource = spendingSource
        self.completion = completion
        categories = AccountsManager.shared.categories

        Task {
            await getSpendingCategories()
        }
    }

    func saveCategoryData() {
        if let selected = selectedSubCategory {
            completion?(selected)
        }
    }
    
    @MainActor
    func getSpendingCategories() async {
        guard categories.isEmpty else { return }
        
        do {
            let manager = AccountsManager.shared
            try await manager.getSpendingCategories()
            self.categories = manager.categories
            
            updateSubject.send(true)
        } catch {
            self.error = error
        }
    }
}
