//
//  SelfEmployedTimeViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 06.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class SelfEmployedTimeViewModel {
    @Published var error: Error?
    @Published var showImportant: Bool = false
    @Published var update: Bool = false
    @Published var next: Bool = false
    
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool
    var selectedMonth: Int?
    var selectedYear: Int?
    var initialMonths: Int?
    
    init(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool = false) {
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings
        self.initialMonths = incomeData?.selfEmploymentData?.months
    }
    
    func setData() {
        guard let years = selectedYear, let months = selectedMonth else { return }
        let newMonths = years * 12 + months
        incomeData?.selfEmploymentData?.months = newMonths
        
        if let initialMonths, newMonths <= 24, initialMonths <= 24 {
            update = true
        } else {
            if newMonths > 11 {
                next = true
            } else {
                showImportant = true
            }
        }
    }
}
