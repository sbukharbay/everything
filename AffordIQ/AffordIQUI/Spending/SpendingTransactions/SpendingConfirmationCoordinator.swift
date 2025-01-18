//
//  SpendingConfirmationCoordinator.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/01/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class SpendingConfirmationCoordinator: NSObject {
    weak var presenter: UINavigationController?
    let transactions: [RecurringTransactionsModel]
    let getStartedType: GetStartedViewType

    init(presenter: UINavigationController, transactions: [RecurringTransactionsModel], getStartedType: GetStartedViewType) {
        self.presenter = presenter
        self.transactions = transactions
        self.getStartedType = getStartedType
    }
}

extension SpendingConfirmationCoordinator: Coordinator {
    public func start() {
        if let presenter = presenter {
            let viewController = SpendingConfirmationViewController()
            viewController.bind(transactions: transactions, getStartedType: getStartedType)

            presenter.pushViewController(viewController, animated: true)
        }
    }
}
