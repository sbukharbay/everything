//
//  NotificationsViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 04/01/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

class NotificationsViewModelTests: XCTestCase {
    var sut: NotificationsViewModel!
    var mockUserSession: UserSessionMock!
    var manager: NotificationManagerMock!
    
    override func setUp() {
        super.setUp()
        manager = NotificationManagerMock()
        mockUserSession = UserSessionMock.getMock()
        sut = NotificationsViewModel(notificationManager: manager, userSession: mockUserSession)
    }
    
    override func tearDown() {
        sut = nil
        manager = nil
        super.tearDown()
    }
    
    // MARK: - Given
    func addNotifications() {
        let calendar = Calendar.current
        manager.addNotification(withTitle: "Hello world",
                                description: "First notification",
                                date: Date())
        
        manager.addNotification(withTitle: "I am running",
                                description: "Second notification",
                                date: calendar.date(byAdding: Calendar.Component.month, value: 2, to: Date())!)
    }
    
    func configureNotificationsManager() {
        mockUserSession.userID = "1122"
        addNotifications()
    }
    
    // MARK: - Testing
//    func test_setupListeners_
    
    func test_cleanNotification_didClean() {
        // given
        addNotifications()
        
        // when
        sut.cleanNotifications()
        
        // then
        XCTAssertEqual(manager.notificationCounter, 0)
    }
    
    func test_notificationListListener_notEmpty() {
        // given
        let expectation = XCTestExpectation(description: #function)
        configureNotificationsManager()
        
        // when
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertFalse(sut.notificationList.isEmpty)
    }
    
    func test_sortSectionsByMonths_sorted() {
        // given
        let expectation = XCTestExpectation(description: #function)
        
        configureNotificationsManager()
        addNotifications()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            expectation.fulfill()
            self?.sut.groupNotificationsByMonths()
        }
        
        sleep(1)
        
        // when
        sut.sortSectionsByMonths()
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertEqual(sut.notificationSections.first!.notifications.count, 2)
    }
    
    func test_groupNotificationByMonths_groupped() {
        // given
        let expectation = XCTestExpectation(description: #function)
        
        configureNotificationsManager()
        addNotifications()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        
        // when
        sut.groupNotificationsByMonths()
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertFalse(sut.notificationSections.isEmpty)
    }
}
