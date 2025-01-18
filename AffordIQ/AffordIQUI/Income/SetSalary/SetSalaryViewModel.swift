//
//  SetSalaryViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 12.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

class SetSalaryViewModel {
    @Published var next: Bool = false
    
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool

    init(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool = false) {
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings
    }

    func showIncomeSummary(salary: String, bonus: String, monthly: String) {
        incomeData?.salary = salary
        incomeData?.bonus = bonus
        incomeData?.monthly = monthly
        next = true
    }
}
