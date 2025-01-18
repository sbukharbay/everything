//
//  MilestoneInformationViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 09/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

struct MilestoneInformationViewModel {
    let pages: [MilestoneInformationViewType]
    var viewType: CarouselViewType

    init(type: CarouselViewType) {
        viewType = type

        switch type {
        case .ownYourFinances:
            pages = [
                .single(Page(imageName: "alfie_tag", headerText: "", bodyText: "Now it's time to Own Your Finances. Our Al friend Lotus will help you see a complete picture of your income, spending and savings.")),
                .many([
                    Page(imageName: "income", headerText: "Income", bodyText: "First we will determine your annual and monthly incomes.\n"),
                    Page(imageName: "savings", headerText: "Savings", bodyText: "Next we will allocate the proportion of your savings that go towards buying your home.\n"),
                    Page(imageName: "spending", headerText: "Spending", bodyText: "Finally we identify any rental payments and other important monthly expenditure.")
                ])
            ]
        case .ownYourFuture:
            pages = [
                .single(Page(imageName: "family", headerText: "", bodyText: "Lotus will help you see into the future and choose where and when you want to buy your home."
                        + "You can then set a budget to bend your future and get there sooner.\n")),
                .many([
                    Page(
                        imageName: "goal", headerText: "Set a Goal",
                        bodyText: "With an understanding of your affordability, search for homes you can afford today and in the future. Choose where and when you want to buy and set a budget to get there.\n"
                    )
                ])
            ]
        }
    }
}
