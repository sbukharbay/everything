//
//  SelfEmployedTypeViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 12.12.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class SelfEmployedTypeViewModel {
    @Published var showNext: Bool = false
    
    var incomeData: IncomeStatusDataModel?
    var getStartedType: GetStartedViewType?
    var isSettings: Bool
    var types: [SelfEmploymentModel] = [
        SelfEmploymentModel(type: .trader, selected: false),
        SelfEmploymentModel(type: .contractor, selected: false),
        SelfEmploymentModel(type: .partner, selected: false),
        SelfEmploymentModel(type: .llp, selected: false),
        SelfEmploymentModel(type: .shareHolder, selected: false),
        SelfEmploymentModel(type: .director, selected: false)
    ]
    
    init(incomeData: IncomeStatusDataModel?, getStartedType: GetStartedViewType?, isSettings: Bool = false) {
        self.incomeData = incomeData
        self.getStartedType = getStartedType
        self.isSettings = isSettings
        
        guard let type = incomeData?.selfEmploymentData?.type else { return }
        
        types.enumerated().forEach { index, item in
            types[index].selected = item.type == type
        }
    }
    
    func next() {
        if let type = types.first(where: { $0.selected })?.type {
            if incomeData?.selfEmploymentData?.type == nil {
                incomeData?.selfEmploymentData = SelfEmploymentData(type: type)
            } else {
                incomeData?.selfEmploymentData?.type = type
            }
            
            showNext = true
        }
    }
}
