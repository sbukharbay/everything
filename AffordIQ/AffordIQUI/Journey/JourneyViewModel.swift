//
//  JourneyViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 08/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation

struct JourneyViewModel {
    
    let styles = AppStyles.shared
    let pages: [Page]

    init() {
        pages = [
            Page(imageName: "get_started", headerText: "GET STARTED", bodyText: "Before we can start you will need to register and link your bank accounts."),
            Page(imageName: "alfie_tag", headerText: "OWN YOUR FINANCES", bodyText: "Next, our AI friend Lotus will help you see a complete picture of your income, spending and savings."),
            Page(imageName: "family", headerText: "OWN YOUR FUTURE", bodyText: "Lotus will help you see into the future and choose where and when you want to buy your home. You can then set a budget to bend your future and get there sooner."),
            Page(
                imageName: "set_compass",
                headerText: "OWN YOUR HOME",
                bodyText: """
                When the time is right, we'll refer you to an MAB mortgage adviser. They will find the right mortgage for you as they walk you through the application process.
                """)
        ]
    }
}
