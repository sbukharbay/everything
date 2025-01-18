//
//  PropertyParametersViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 11.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class PropertyParametersViewModelTests: XCTestCase {
    private var sut: PropertyParametersViewModel!
    private var affordabilitySourceMock: AffordabilityServiceMock!
    private var propertySourceMock: PropertyServiceMock!
    private var mockUserSession: UserSessionMock!
    
    override func setUp() {
        super.setUp()
        
        affordabilitySourceMock = AffordabilityServiceMock()
        propertySourceMock = PropertyServiceMock()
        mockUserSession = UserSessionMock.getMock()
        let parameters = ChosenPropertyParameters(suggestion: Suggestion(value: "Glasgow"), homeValue: 120000.0)
        
        sut = PropertyParametersViewModel(homeValue: 0.0, parameters: parameters, months: 12, isDashboard: false, session: mockUserSession, propertySource: propertySourceMock, affordabilitySource: affordabilitySourceMock)
    }
    
    override func tearDown() {
        sut = nil
        affordabilitySourceMock = nil
        propertySourceMock = nil
        mockUserSession = nil
        super.tearDown()
    }
    
    func test_getMonthsUntilAffordable_didShowError() async {
        // given
        sut.session.userID = "error"
        
        // when
        await sut.getMonthsUntilAffordable()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_autocomplete() async {
        // given
        let text = "Glas"
        
        // when
        await sut.autocomplete(text)
        
        // then
        XCTAssertNotEqual(sut.suggestions, [])
    }
    
    func test_autocomplete_lessThanMinimumLength() async {
        // given
        let text = "G"
        
        // when
        await sut.autocomplete(text)
        
        // then
        XCTAssertTrue(sut.isFilter)
    }
    
    func test_autocomplete_didShowError() async {
        // when
        await sut.autocomplete("error")
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_prepareResults() {
        // when
        sut.prepareResults()
        
        // then
        XCTAssertNotNil(sut.chosenPropertyParameters)
    }
}
