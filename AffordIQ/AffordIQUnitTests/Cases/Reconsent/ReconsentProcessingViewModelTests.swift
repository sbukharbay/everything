//
//  ReconsentProcessingViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 26.09.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI
@testable import AffordIQFoundation

final class ReconsentProcessingViewModelTests: XCTestCase {
    var sut: ReconsentProcessingViewModel!
    var obSourceMock: OpenBankingServiceMock!
    var accountsSourceMock: AccountsServiceMock!
    var userSessionMock: SessionType!
    
    override func setUp() {
        super.setUp()
        let providers = [ReconsentProvider(provider: "mock", renew: true), ReconsentProvider(provider: "mock", renew: false)]
        obSourceMock = OpenBankingServiceMock()
        accountsSourceMock = AccountsServiceMock()
        userSessionMock = UserSessionMock.getMock()
        userSessionMock.userID = "reconsent"
        sut = ReconsentProcessingViewModel(providers: ReconsentRequestModel(providers: providers), session: userSessionMock, openBankingSource: obSourceMock, accountsSource: accountsSourceMock, type: .reconsent)
    }

    override func tearDown() {
        sut = nil
        obSourceMock = nil
        accountsSourceMock = nil
        super.tearDown()
    }
    
    func test_setAuthorised_emptyCode() async {
        // when
        await sut.setAuthorised(
            request: RMAuthoriseBank(code: "", scope: "read", state: "all", providerID: "mock"),
            id: "mock")
        
        sut.noConsent()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_setAuthorised_didCatchError() async {
        // when
        await sut.setAuthorised(request: RMAuthoriseBank(code: "error", scope: "test", state: "test", providerID: "test"), id: "test")
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_setAuthorised_manualRenew() async {
        // given
        sut.trueLayerResponse = [TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: "")),
                                 TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: ""))]
        
        // when
        await sut.setAuthorised(request: RMAuthoriseBank(code: "code", scope: "info", state: "state", providerID: "mock"), id: "mock")
        
        // then
        XCTAssertNotNil(sut.manualRenew)
    }
    
    func test_skip_manualRenew() async {
        // given
        sut.trueLayerResponse = [TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: "")),
                                 TrueLayerModel(providerID: "mock", response: TrueLayerResponse(accessToken: "", actionNeeded: .authentication, refreshToken: "", userInputLink: ""))]
        
        // when
        sut.skip()
        
        // then
        XCTAssertNotNil(sut.manualRenew)
    }
    
    func test_skip_noDates() async {
        // given
        sut.trueLayerResponse?.removeAll()
        
        // when
        sut.skip()
        
        // then
        XCTAssertNotNil(sut.noDates)
    }
    
    func test_reconsent_noUser() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.reconsent()
        await sut.getAccountsDates()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_getAccountsDates_noDates() async {
        // given
        userSessionMock.userID = "id"
        sut.providers = ReconsentRequestModel(providers: [])
        
        // when
        await sut.getAccountsDates()
        
        // then
        XCTAssertNotNil(sut.noDates)
    }
    
    func test_reconsent_catchError() async {
        // given
        userSessionMock.userID = "error"
        
        // when
        await sut.reconsent()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_reconsent_noResponse() async {
        // given
        userSessionMock.userID = "trueLayer"
        
        // when
        await sut.reconsent()
        
        // then
        XCTAssertNotNil(sut.error)
    }
}
