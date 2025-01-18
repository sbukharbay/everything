//
//  DepositViewMock.swift
//  AffordIQ
//
//  Created by Sultangazy Bukharbay on 14.12.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
@testable import AffordIQUI
@testable import AffordIQFoundation

class DepositViewMock: DepositView {
    var isLogged = false
    var presentedNext = false
    
    func set(currentDeposit: String?) {
    }
    
    func set(savings: NSAttributedString?) {
    }
    
    func set(externalCapitalAmount: AffordIQFoundation.MonetaryAmount?, externalCapitalDescription: String) {
    }
    
    func present(accounts: [AffordIQUI.DepositAccount], animated: Bool) {
    }
    
    func presentNext() {
        presentedNext = true
    }
    
    func addAccounts(hide: Bool) {
    }
    
    func skip(hide: Bool) {
    }
    
    func back() {
    }
    
    func present(error: Error) {
    }
    
    func present(error: Error, completion: (() -> Void)?) {
    }
}
