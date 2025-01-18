//
//  SpendingConfirmationViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 17/04/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
@testable import AffordIQUI
@testable import AffordIQNetworkKit
@testable import AffordIQFoundation

final class SpendingConfirmationViewModelTests: XCTestCase {
    var sut: SpendingConfirmationViewModel!
    var userSessionMock: UserSessionMock!
    var transactionsSourceMock: TransactionsServiceMock!
    
    override func setUp() {
        super.setUp()
        userSessionMock = UserSessionMock.getMock()
        transactionsSourceMock = TransactionsServiceMock()
        sut = SpendingConfirmationViewModel(transactions: [], getStartedType: .spending, transactionsSource: transactionsSourceMock, userSession: userSessionMock)
    }
    
    override func tearDown() {
        sut = nil
        userSessionMock = nil
        super.tearDown()
    }
    
    // MARK: - Given
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Testing
    func test_getSpendingTransactions_didThrowError() async {
        // given
        userSessionMock = nil
        
        // when
        await sut.getSpendingTransactions()
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_getSpendingTransactions_didUpdateTable() async {
        // given
        userSessionMock.userID = "success"
        
        var didUpdate = false
        let expectation = XCTestExpectation(description: #function)
        sut.updateTableSubject
            .sink { _ in
                didUpdate = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        await sut.getSpendingTransactions()
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didUpdate)
    }
    
    func test_confirmTransaction_didAppendCurrent() {
        // given
        sut.savedSpendingData = []
        sut.currentSpending = RecurringTransactionsModel(
            transactionDescription: "",
            amount: MonetaryAmount(amount: 10),
            paymentPattern: "",
            categoryId: 1,
            categoryName: "Category Name",
            transactionsIdentifiers: []
        )
        
        // when
        sut.confirmTransaction(save: true)
        
        // then
        XCTAssertFalse(sut.savedSpendingData.isEmpty)
    }
    
    func test_confirmTransaction_didUpdateTable() {
        // given
        sut.spendingStack.append(
            RecurringTransactionsModel(
                transactionDescription: "",
                amount: MonetaryAmount(amount: 10),
                paymentPattern: "",
                categoryId: 1,
                categoryName: "Category Name",
                transactionsIdentifiers: []
            )
        )
        
        var didUpdate = false
        let expectation = XCTestExpectation(description: #function)
        sut.updateTableSubject
            .sink { _ in
                didUpdate = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        sut.confirmTransaction(save: true)
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didUpdate)
    }
    
    func test_confirmTransaction_didShowCompletion() {
        // given
        var didShow = false
        let expectation = XCTestExpectation(description: #function)
        sut.showCompletionSubject
            .sink { _ in
                didShow = true
                expectation.fulfill()
            }
            .store(in: &subscriptions)
        
        // when
        sut.confirmTransaction(save: true)
        wait(for: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didShow)
    }
    
    func test_saveCategorisedTransactions_didThrowError() async {
        // given
        userSessionMock.userID = nil
        
        // when
        await sut.saveCategorisedTransactions()
        
        // then
        XCTAssertEqual(sut.error as? NetworkError, .unauthorized)
    }
    
    func test_saveCategorisedTransactions_didRecatigorise() async {
        // given
        userSessionMock.userID = "success"
        sut.currentSpending = RecurringTransactionsModel(
            transactionDescription: "",
            amount: MonetaryAmount(amount: 10),
            paymentPattern: "",
            categoryId: 2,
            categoryName: "categoryName",
            transactionsIdentifiers: [
                TransactionsIdentifiers(accountId: "1", transactionDateTime: "1"),
                TransactionsIdentifiers(accountId: "1", transactionDateTime: "2"),
                TransactionsIdentifiers(accountId: "1", transactionDateTime: "3"),
                TransactionsIdentifiers(accountId: "1", transactionDateTime: "4")
            ]
        )
        sut.currentCategory = ChildCategoriesModel(id: 2, name: "Hello")
        
        // when
        await sut.saveCategorisedTransactions()
        
        // then
        XCTAssertTrue(transactionsSourceMock.didRecatigorise)
    }
}
