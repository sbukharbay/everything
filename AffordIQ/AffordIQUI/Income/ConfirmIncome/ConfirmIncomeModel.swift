//
//  ConfirmIncomeModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation

struct ConfirmIncomeModel {
    var subTitle: String
    var value: String
}

struct IncomeStatusDataModel {
    var employmentStatus: EmploymentStatusType
    var salary: String
    var bonus: String
    var monthly: String
    var selfEmploymentData: SelfEmploymentData?
}

struct SelfEmploymentModel {
    var type: SelfEmploymentType
    var selected: Bool
}

struct SelfEmploymentData {
    var type: SelfEmploymentType
    var months: Int?
    var incomeBT: MonetaryAmount?
    var incomeAT: MonetaryAmount?
    var profitBT: MonetaryAmount?
    var profitAT: MonetaryAmount?
}
