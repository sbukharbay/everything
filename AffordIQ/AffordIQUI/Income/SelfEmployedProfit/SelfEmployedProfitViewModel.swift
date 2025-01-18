//
//  SelfEmployedProfitViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 08.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class SelfEmployedProfitViewModel {
    @Published var next: Bool = false
    
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool
    
    init(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool = false) {
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings
    }
    
    func next(_ btp: String, _ atp: String) {
        if let months = incomeData?.selfEmploymentData?.months, months < 24 {
            incomeData?.selfEmploymentData?.profitBT = MonetaryAmount(amount: Decimal(btp.formatAndConvert()))
            incomeData?.selfEmploymentData?.profitAT = MonetaryAmount(amount: Decimal(atp.formatAndConvert()))
        } else {
            incomeData?.selfEmploymentData?.incomeBT = MonetaryAmount(amount: Decimal(btp.formatAndConvert()))
            incomeData?.selfEmploymentData?.incomeAT = MonetaryAmount(amount: Decimal(atp.formatAndConvert()))
        }
        
        next = true
    }
}
