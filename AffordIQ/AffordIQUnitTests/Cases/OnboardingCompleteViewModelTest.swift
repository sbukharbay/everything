//
//  OnboardingCompleteViewModelTest.swift
//  AffordIQAPITests
//
//  Created by Asilbek Djamaldinov on 27/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
import Amplitude
@testable import AffordIQUI
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

final class OnboardingCompleteViewModelTest: XCTestCase {
    var sut: OnboardingCompleteViewModel!
    var userSessionMock: SessionType!
    var userSourceMock: UserServiceMock!
    var amplitude: AmplitudeMock!
    
    override func setUp() {
        super.setUp()
        userSourceMock = UserServiceMock()
        userSessionMock = UserSessionMock.getMock()
        amplitude = AmplitudeMock()
        sut = OnboardingCompleteViewModel(userSource: userSourceMock, authSession: userSessionMock, amplitude: amplitude)
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        userSourceMock = nil
        amplitude = nil
        super.tearDown()
    }
    
    // MARK: - Given
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_showDashboard_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.showDashboard()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_showDashboard_() async {
        // given
        userSessionMock.userID = "move"
        var isMoved = false
        let expectation = XCTestExpectation(description: #function)
        
        sut.moveToDashboardSubject
            .receive(on: DispatchQueue.main)
            .sink { willMove in
                isMoved = willMove
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.showDashboard()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(isMoved)
    }
    
    func test_logEvent_didLog() {
        // when
        sut.logEvent(key: "hello")
        
        // then
        XCTAssertTrue(amplitude.isLogged)
    }
}
