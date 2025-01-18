//
//  AffordabilityInformationCarouselViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 24/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

class AffordabilityInformationCarouselViewModelTests: XCTestCase {
    var sut: AffordabilityInformationCarouselViewModel!
    
    override func setUp() {
        super.setUp()
        sut = AffordabilityInformationCarouselViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_init() {
        XCTAssertFalse(sut.isDashboard)
    }
}
