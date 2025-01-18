//
//  PropertySearchViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 11.10.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class PropertySearchViewModelTests: XCTestCase {
    private var sut: PropertySearchViewModel!
    private var goalSourceMock: GoalServiceMock!
    private var propertySourceMock: PropertyServiceMock!
    private var mockUserSession: UserSessionMock!
    private var listing: Listing!
    
    override func setUp() {
        super.setUp()
        
        goalSourceMock = GoalServiceMock()
        propertySourceMock = PropertyServiceMock()
        mockUserSession = UserSessionMock.getMock()
        mockUserSession.userID = "id"
        let suggestion = Suggestion(value: "Glasgow")
        let parameters = ChosenPropertyParameters(suggestion: suggestion, homeValue: 120000.0)
        
        sut = PropertySearchViewModel(search: suggestion, parameters: parameters, mortgageLimits: nil, propertySource: propertySourceMock, userSession: mockUserSession, goalSource: goalSourceMock, months: 12)
        
        listing = Listing.testListing()
    }
    
    override func tearDown() {
        sut = nil
        goalSourceMock = nil
        propertySourceMock = nil
        mockUserSession = nil
        super.tearDown()
    }
    
    func test_isAffordable() {
        // when
        let isAffordable = sut.isAffordable(listing: listing)
        
        // then
        XCTAssertFalse(isAffordable)
    }
    
    func test_willApply() {
        // given
        let filter = PropertySearchFilter()
        // when
        sut.willApply(filter: filter)
        
        // then
        XCTAssertEqual(sut.searchFilter, filter)
    }
    
    func test_setPropertyGoal() async {
        // given
        sut.userSession.userID = "userID"
        
        // when
        await sut.setPropertyGoal(listing: listing)
        
        // then
        XCTAssertNotNil(sut.showNext)
    }
    
    func test_nextPage() {
        // given
        sut.results = [PropertySearchResult.result(listing: listing)]
        sut.userSession.userID = "userID"
        sut.availableResults = 10
        
        // when
        sut.nextPage()
    }
    
    func test_fetchProperties_didShowError() async {
        // given
        let request = RMGetPropertyList(bedrooms: nil, price: 100000.0, pageNumber: 1, pageSize: 200, area: "Error", propertyType: nil, userId: "")
        
        // when
        await sut.fetchProperties(request: request)
        
        // then
        XCTAssertTrue(sut.zooplaErrorAlert)
    }
}
