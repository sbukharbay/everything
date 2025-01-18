//
//  JourneyViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 18.12.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

final class JourneyViewModelTests: XCTestCase {
    var sut: JourneyViewModel?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_init() throws {
        // when
        sut = JourneyViewModel()
        
        // then
        XCTAssertNotNil(sut?.pages)
    }
}
