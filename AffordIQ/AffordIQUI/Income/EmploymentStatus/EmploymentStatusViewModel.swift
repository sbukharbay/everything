//
//  EmploymentStatusViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 15.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

class EmploymentStatusViewModel {
    @Published var error: Error?
    @Published var showNext: Bool = false
    @Published var confirmIncome: Bool = false
    
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool
    var isSelfEmployed: Bool = false
    var statuses: [EmploymentStatusModel] = [
        EmploymentStatusModel(status: .employed, selected: false),
        EmploymentStatusModel(status: .selfEmployed, selected: false)
    ]

    init(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool = false) {
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings

        statuses.enumerated().forEach { index, item in
            if item.status == incomeData?.employmentStatus {
                statuses[index].selected = true
            }
        }
    }

    func showNext(_ selected: EmploymentStatusModel) {
        if incomeData == nil {
            incomeData = IncomeStatusDataModel(employmentStatus: selected.status, salary: "", bonus: "", monthly: "")
        } else {
            incomeData?.employmentStatus = selected.status
        }
        
        isSelfEmployed = selected.status == .selfEmployed
        showNext = true
    }

    func confirmIncomeSummary(_ selected: EmploymentStatusModel) {
        incomeData?.employmentStatus = selected.status

        switch incomeData?.employmentStatus {
        case .selfEmployed:
            if incomeData?.selfEmploymentData?.type == nil {
                isSelfEmployed = true
                showNext = true
                return
            }
        default:
            if let salary = incomeData?.salary, salary.isEmpty || incomeData?.salary == nil {
                isSelfEmployed = false
                showNext = true
                return
            }
        }
        
        confirmIncome = true
    }
}
