//
//  ExternalCapitalViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Combine
import UIKit
import AffordIQControls
import AffordIQNetworkKit
import AffordIQAuth0

protocol OutsideCapitalView: AnyObject {
    func set(description: String?)
    func set(value: MonetaryAmount)
    func endEditing(close: Bool)
}

enum OutsideCapitalFieldType: CaseIterable {
    case amount
}

class ExternalCapitalViewModel: FormViewModel {
    typealias FieldType = OutsideCapitalFieldType
    
    @Published var error: Error?

    weak var view: OutsideCapitalView?

    var externalCapital: ExternalCapitalResponse?

    var subscriptions: Set<AnyCancellable> = []
    var isNew: Bool = true
    var description = ""
    
    private let userSession: SessionType
    private let depositSource: DepositSource

    init(
        view: OutsideCapitalView,
        userSession: SessionType = Auth0Session.shared,
        depositSource: DepositSource = DepositService()
    ) {
        self.view = view
        self.userSession = userSession
        self.depositSource = depositSource
    }

    func isValid(field: OutsideCapitalFieldType, values: [OutsideCapitalFieldType: String]) -> Bool {
        guard let value = values[field]?.sanitized, !value.isEmpty else {
            switch field {
            default:
                return false
            }
        }

        switch field {
        case .amount:
            if value.formatAndConvert() > 10000000 { return false }
            return true
        }
    }

    func validationMessage(field: OutsideCapitalFieldType,
                           values: [OutsideCapitalFieldType: String]) -> String? {
        let isValid = self.isValid(field: field, values: values)
        switch field {
        case .amount:
            if !isValid {
                if let value = values[field]?.sanitized, value.formatAndConvert() > 10000000 {
                    return NSLocalizedString(
                        "We are unable to accept external savings of greater than £10,000,000. You can retry with a lower amount.",
                        bundle: uiBundle,
                        comment: "We are unable to accept external savings of greater than £10,000,000. You can retry with a lower amount.")
                }
                return NSLocalizedString("Please enter a valid amount.", bundle: uiBundle, comment: "Please enter a valid amount.")
            }
            return nil
        }
    }

    func submit(values: [OutsideCapitalFieldType: String]) {
        guard let value = values[.amount]?.sanitized, !value.isEmpty else { return }
        let amount = MonetaryAmount(amount: Decimal(value.formatAndConvert()))
        
        Task {
            if isNew {
                await createExternalCapital(description: description, amount: amount)
            } else {
                await updateExternalCapital(description: description, amount: amount)
            }
        }
    }
    
    @MainActor
    func createExternalCapital(description: String, amount: MonetaryAmount) async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let model = RMExternalCapital(description: description, value: amount)

            try await depositSource.createExternalCapital(userID: userID, model: model)
            
            isNew = false
            view?.endEditing(close: true)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func updateExternalCapital(description: String, amount: MonetaryAmount) async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let model = RMExternalCapital(description: description, value: amount)
            
            try await depositSource.updateExternalCapital(userID: userID, model: model)
            
            isNew = false
            view?.endEditing(close: true)
        } catch {
            self.error = error
        }
    }
}
