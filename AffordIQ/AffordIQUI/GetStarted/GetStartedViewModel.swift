//
//  GetStartedViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 12.10.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

class GetStartedViewModel {
    var incomeData: IncomeStatusDataModel?
    var viewType: GetStartedViewType = .initial
    let getStartedData: [Page]
    let ownYourFinancesData: [Page]
    let ownYourFutureData: [Page]

    init() {
        getStartedData = [
            Page(imageName: "registration", headerText: "Registration", bodyText: "To begin you will need to set-up an account."),
            Page(imageName: "linked_accounts", headerText: "Link Bank Accounts", bodyText: "Next you will need to securely link your bank accounts.")
        ]
        ownYourFinancesData = [
            Page(imageName: "income", headerText: "Income", bodyText: "First we will determine your annual and monthly incomes."),
            Page(imageName: "savings", headerText: "Savings", bodyText: "Next we will allocate the proportion of your savings that will go towards buying your home."),
            Page(imageName: "spending", headerText: "Spending", bodyText: "Finally we identify any rental payments and other important monthly expenditure Lotus can't categorise.")
        ]
        ownYourFutureData = [
            Page(imageName: "goal", headerText: "Set a Goal", bodyText: "")
        ]
    }
}
