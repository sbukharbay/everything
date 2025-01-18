//
//  AddMoreAccountsViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 05/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQAuth0

struct AddMoreAccountsViewModel {
    var getStartedType: GetStartedViewType!
    var isSettings: Bool = false
    var session: SessionType
    
    var isOnboardingCategorisationDone: Bool {
        AccountsManager.shared.isOnboardingCategorisationDone
    }
    
    init(getStartedType: GetStartedViewType?, isSettings: Bool = false) {
        self.isSettings = isSettings
        self.session = Auth0Session.shared
        
        if let type = getStartedType {
            self.getStartedType = type
        } else {
            self.getStartedType = .linkedBankAccounts
        }
    }
}
