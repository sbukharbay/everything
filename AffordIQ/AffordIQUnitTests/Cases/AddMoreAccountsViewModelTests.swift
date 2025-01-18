//
//  AddMoreAccountsViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 10.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

final class AddMoreAccountsViewModelTests: XCTestCase {
    var sut: AddMoreAccountsViewModel?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_init() throws {
        // when
        sut = AddMoreAccountsViewModel(getStartedType: .initial)
        
        // then
        XCTAssertNotNil(sut?.getStartedType)
    }
}
