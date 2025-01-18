//
//  TotalSavingsHeaderView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 24/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Combine
import UIKit
import AffordIQControls
import AffordIQNetworkKit
import AffordIQAuth0

class TotalSavingsHeaderView: UITableViewHeaderFooterView, TableViewElement {
    static var reuseIdentifier = "TotalSavings"

    @IBOutlet var title: UILabel?
    @IBOutlet var total: UILabel?
    @IBOutlet var info: UILabel?

    var subscriptions: Set<AnyCancellable> = []
    
    private var depositSource: DepositSource?
    private var userSession: SessionType?

    func bind(
        userSession: SessionType = Auth0Session.shared,
        depositSource: DepositSource = DepositService()
    ) {
        self.userSession = userSession
        self.depositSource = depositSource
        
        subscriptions.removeAll()
        Task {
            let depositAmount = await setDepositBalance()
            let externalAmount = await setExternalCapital()
            
            let savingsAccountAmount = (depositAmount.amount ?? 0) > 0 ? (depositAmount - externalAmount) : MonetaryAmount(amount: 0)
            setSavings(savingsAccountAmount)
        }

        style(styles: AppStyles.shared)

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: bounds.maxY - 12, width: bounds.width, height: layer.shadowRadius)).cgPath
    }
    
    func setSavings(_ amount: MonetaryAmount) {
        total?.text = amount.shortDescription
    }
    
    @MainActor func setDepositBalance() async -> MonetaryAmount {
        var depositAmount = MonetaryAmount(amount: 0)
        let depositBalance = await getDepositBalance()
        
        if let amount = depositBalance?.depositBalance {
            depositAmount = amount
        }
        
        return depositAmount
    }
    
    @MainActor func setExternalCapital() async -> MonetaryAmount {
        var externalAmount = MonetaryAmount(amount: 0)
        let externalCapital = await getExternalCapital()
        
        if let amount = externalCapital?.externalCapitalAmount {
            externalAmount = amount
        }
        
        return externalAmount
    }
    
    @MainActor func getDepositBalance() async -> DepositBalanceResponse? {
        do {
            guard let userID = userSession?.userID else { throw NetworkError.unauthorized }
            return try await depositSource?.getBalance(userID: userID)
        } catch {
            return nil
        }
    }
    
    @MainActor func getExternalCapital() async -> ExternalCapitalResponse? {
        do {
            guard let userID = userSession?.userID else { throw NetworkError.unauthorized }
            
            return try await depositSource?.getExternalCapital(userID: userID)
        } catch {
            return nil
        }
    }
}

extension TotalSavingsHeaderView: Stylable {
    func apply(styles: AppStyles) {
        for view in subviews {
            if let view = view as? Stylable {
                view.apply(styles: styles)
            }
        }
    }
}
