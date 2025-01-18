//
//  FeedbackFormViewModelTests.swift
//  AffordIQAPITests
//
//  Created by Asilbek Djamaldinov on 12/12/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQNetworkKit
@testable import AffordIQUI
@testable import AffordIQFoundation

class FeedbackFormViewModelTests: XCTestCase {
    var sut: FeedbackFormViewModel!
    var mockNetwork: FeedbackServiceMock!
    
    override func setUp() {
        super.setUp()
        mockNetwork = FeedbackServiceMock()
        sut = FeedbackFormViewModel(networkSource: mockNetwork, className: className)
    }
    
    override func tearDown() {
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    // MARK: - Given
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let userMock = UserDetailsMock.getMock()
    let comment = "Hello"
    
    var className: String {
        "FeedbackFormViewController"
    }
    
    // MARK: - Testing
    func test_init_sets_session() {
        XCTAssertEqual(sut.network as? FeedbackServiceMock, mockNetwork)
    }
    
    func test_init_sets_className() {
        XCTAssertEqual(sut.className, className)
    }
    
    func test_init_sets_reasons() {
        // given
        let reasons: [FeedbackReasonModel] = [
            FeedbackReasonModel(reason: "It doesn't work", selected: false),
            FeedbackReasonModel(reason: "I don't know what to do", selected: false),
            FeedbackReasonModel(reason: "I don't like something", selected: false),
            FeedbackReasonModel(reason: "I really like something", selected: false),
            FeedbackReasonModel(reason: "Other", selected: false)
        ]
        
        // then
        XCTAssertEqual(sut.reasons, reasons)
    }
    
    func testAppVersion_whenSendingFeedback_didVersionEqual() {
        // when
        let sutVersion = sut.getApplicationVersion()
        
        // then
        XCTAssertEqual(sutVersion, appVersion)
    }
    
    func testRMFeedback_getRMFeedback_didRMEqual() {
        // given
        guard let appVersion else {
            XCTFail("No app version error")
            return
        }
        
        sut.reasons[0].selected = true
        sut.fullName = userMock.fullName
        sut.email = userMock.name
        
        let version = "App version: " + appVersion + ". Device: " + UIDevice.modelName + ". System: iOS " + UIDevice.current.systemVersion + "."
        let rmFeedback = RMFeedback(
            name: userMock.fullName,
            email: userMock.name,
            comment: comment,
            screenName: className,
            reason: "It doesn't work",
            appVersion: version,
            osType: "IOS")
        
        // when
        let sutFeedback = try? sut.getRMFeedback(comment: comment)
        
        // then
        XCTAssertEqual(sutFeedback, rmFeedback)
    }
    
    func testShowError_getRMFeedback_reasonNotChoosed_didShowError() {
        // when
        do {
            _ = try sut.getRMFeedback(comment: comment)
        } catch {
            sut.error = error
            sut.showError = true
        }
        
        // then
        XCTAssertTrue(sut.showError)
    }
    
    func testGetRMFeedback_whenCommentEmpty_didNilReturn() {
        // given
        sut.reasons[0].selected = true
        
        // when
        let returned = try? sut.getRMFeedback(comment: "")
        
        // then
        XCTAssertNil(returned)
    }
    
    func testResponse_whenSubmit_didFinishSuccessfully() async {
        // given
        let comment = "Success"
        
        sut.reasons[0].selected = true
        sut.email = "email@email.com"
        sut.fullName = "name"
        
        // when
        await sut.submit(comment: comment)
        
        // then
        XCTAssertTrue(sut.isCompleted)
    }
    
    func testResponse_whenSubmit_didFinishWithError() async {
        // given
        let comment = "Failure"
        
        // when
        await sut.submit(comment: comment)
        
        // then
        XCTAssertNotNil(sut.error)
    }
}
