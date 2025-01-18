//
//  AffordabilityInformationCarouselViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/12/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

struct AffordabilityInformationCarouselViewModel {
    var pages: [[Page]] =
        [[Page(imageName: "mortgage_gradient", headerText: "Mortgage", bodyText: "When buying a home you will likely need to borrow money from the bank, this is called a mortgage.\n"),
          Page(imageName: "deposit", headerText: "Deposit", bodyText: "The bank will not lend you all of the money needed to purchase your home. The difference between the value of the home vs the mortgage is called the deposit.\n")],
         [Page(imageName: "repayments", headerText: "Repayments", bodyText: "Throughout the lifetime of your loan you will be required to make monthly repayments. A bank will not lend to you more than you can afford to pay.\n"),
          Page(
              imageName: "LTV",
              headerText: "Loan to Value Ratio",
              bodyText: "The Loan to Value ratio is the percentage (%) of the property value that you borrow from the bank as a mortgage. The remaining amount is your deposit.\n"
          )],
         [Page(imageName: "savings", headerText: "Savings", bodyText: "Select how much you put away each month for buying a home."),
          Page(imageName: "property", headerText: "Property", bodyText: "Search for a property you can afford in the area you wish to live."),
          Page(imageName: "deposit_goal", headerText: "Deposit", bodyText: "Set the size of the deposit and see how it will affect the time until you can buy."),
          Page(imageName: "repayments", headerText: "Budget", bodyText: "Set budget goals to maximise your savings and complete your goal sooner.")]]
    var isDashboard: Bool
    
    init(isDashboard: Bool = false) {
        self.isDashboard = isDashboard
    }
}
