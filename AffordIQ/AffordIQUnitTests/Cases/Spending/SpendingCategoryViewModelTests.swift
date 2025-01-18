//
//  SpendingCategoryViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Asilbek Djamaldinov on 10/02/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
import Combine
@testable import AffordIQUI
@testable import AffordIQFoundation

class SpendingCategoryViewModelTests: XCTestCase {
    var sut: SpendingCategoryViewModel!
    var mockNetwork: SpendingServiceMock!
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        mockNetwork = SpendingServiceMock()
        sut = SpendingCategoryViewModel(spendingSource: mockNetwork)
    }
    
    override func tearDown() {
        sut = nil
        mockNetwork = nil
        super.tearDown()
    }
    
    // MARK: - Given
    func getSpendingCategoryResponse() -> SpendingCategoryResponse {
        let model = SpendingCategoriesModel(categoryId: 1, categoryName: "New category", childCategory: [])
        
        return SpendingCategoryResponse(spendingCategories: [model], statusCode: 200)
    }
    
    // MARK: - Testing
    func test_whenSaveCategoryDataCalled_completionCalled() {
        // given
        var called = false
        let completion: ((ChildCategoriesModel) -> Void) = { _ in
            called = true
        }
        sut.selectedSubCategory = ChildCategoriesModel(id: 1, name: "ChildCategory")
        sut.completion = completion
        
        // when
        sut.saveCategoryData()
        
        // then
        XCTAssertTrue(called)
    }
    
    func test_getSpendingCategories_categoriesReceived() async {
        // given
        let responce = getSpendingCategoryResponse()
        let categories = responce.spendingCategories
        
        // when
        await sut.getSpendingCategories()
        
        // then
        XCTAssertEqual(categories.first?.categoryId, sut.categories.first?.categoryId)
        XCTAssertEqual(categories.first?.categoryName, sut.categories.first?.categoryName)
    }
    
    func test_getSpendingCategories_errorCatched() async {
        // given
        mockNetwork.willThrowError = true
        
        // when
        await sut.getSpendingCategories()
        
        // then
        XCTAssertNotNil(sut.error)
    }
    
    func test_addParentCategoryToChild_categoryUpdated() async {
        // given
        let response = getSpendingCategoryResponse()
        let category = response.spendingCategories.first!
        let child = ChildCategoriesModel(id: category.categoryId, name: "General")
        
        // when
        await sut.getSpendingCategories()
        
        guard let sutChildCategory = sut.categories.first?.childCategory.first else {
            XCTFail("No SUT child category")
            return
        }
        
        // then
        XCTAssertEqual(sutChildCategory.categoryId, child.categoryId)
        XCTAssertEqual(sutChildCategory.categoryName, child.categoryName)
    }
    
    func test_getSpendingCategories_subjectSent() async {
        // given
        let expectation = XCTestExpectation(description: #function)
        var didUpdate = false
        sut.updateSubject
            .sink { willUpdate in
                guard willUpdate else { return }
                expectation.fulfill()
                didUpdate = willUpdate
            }
            .store(in: &subscriptions)
        
        // when
        await sut.getSpendingCategories()
        
        await fulfillment(of: [expectation], timeout: 3.0)
        
        // then
        XCTAssertTrue(didUpdate)
    }
}
