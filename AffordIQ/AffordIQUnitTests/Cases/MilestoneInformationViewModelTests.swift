//
//  MilestoneInformationViewModelTests.swift
//  AffordIQUnitTests
//
//  Created by Sultangazy Bukharbay on 27/03/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import XCTest
@testable import AffordIQUI

class MilestoneInformationViewModelTests: XCTestCase {
    var sut: MilestoneInformationViewModel!
    
    override func setUp() {
        super.setUp()
        sut = MilestoneInformationViewModel(type: .ownYourFinances)
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_init_withOwnYourFinances() {
        // given
        let page = MilestoneInformationViewType.single(Page(imageName: "alfie_tag", headerText: "", bodyText: "Now it's time to Own Your Finances. Our Al friend Lotus will help you see a complete picture of your income, spending and savings."))
        
        // when
        sut = MilestoneInformationViewModel(type: .ownYourFinances)
        
        // then
        XCTAssertEqual(sut.viewType, .ownYourFinances)
        XCTAssertEqual(sut.pages[0], page)
    }
    
    func test_init_withOwnYourFuture() {
        // given
        let page = MilestoneInformationViewType.single(
            Page(imageName: "family", headerText: "", bodyText: "Lotus will help you see into the future and choose where and when you want to buy your home." + "You can then set a budget to bend your future and get there sooner.\n")
        )
        
        // when
        sut = MilestoneInformationViewModel(type: .ownYourFuture)
        
        // then
        XCTAssertEqual(sut.viewType, .ownYourFuture)
        XCTAssertEqual(sut.pages[0], page)
    }
}
