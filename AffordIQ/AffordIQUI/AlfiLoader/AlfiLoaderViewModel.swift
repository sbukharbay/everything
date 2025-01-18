//
//  AlfiLoaderViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27.01.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

enum AlfiViewType {
    case processingTransactions
    case completingCategorisation
}

enum LoadingStates {
    case bouncing(Double)
    case textDelay
    case coffeeBreak
    case failure
}

class AlfiLoaderViewModel {
    @Published var error: Error?
    var completedSubject = PassthroughSubject<Bool, Never>()
    var currentState: LoadingStates = .bouncing(5.0)
    var currentViewType: AlfiViewType = .processingTransactions
    var isTransactionsCompleted = false
    var isAffordabilityCompleted = false
    var recurringPaymentsResponse: [RecurringTransactionsModel] = []
    var getStartedType: GetStartedViewType
    @Published var isTransactionsEmpty: Bool = false
    
    private let transactionsSource: TransactionsSource
    private let affordabilitySource: AffordabilitySource
    private let userSource: UserSource
    private let authSession: SessionType
    
    init(isSpending: Bool = false,
         getStartedType: GetStartedViewType,
         transactionsSource: TransactionsSource = TransactionsService(),
         affordabilitySource: AffordabilitySource = AffordabilityService(),
         userSource: UserSource = UserService(),
         authSession: SessionType = Auth0Session.shared) {
        self.transactionsSource = transactionsSource
        self.affordabilitySource = affordabilitySource
        self.userSource = userSource
        self.authSession = authSession
        self.getStartedType = getStartedType
        
        if isSpending {
            Task {
                await confirmCategorisation()
            }
            currentViewType = .completingCategorisation
        } else {
            getTransactionsStatus()
        }
    }

    func getTransactionsStatus() {
        Task {
            do {
                guard let userID = authSession.userID else { throw NetworkError.unauthorized }
                let response = try await transactionsSource.getTransactionsStatus(userID: userID)
                if response.isStepCompleted {
                    recurringPaymentsResponse = try await transactionsSource.getTransactionsSpending(userID: userID).recurringPayments
                    isTransactionsEmpty = recurringPaymentsResponse.isEmpty
                }
                isTransactionsCompleted = response.isStepCompleted
                completedSubject.send(response.isStepCompleted)
            } catch {
                completedSubject.send(false)
                self.error = error
            }
        }
    }

    func getAffordabilityStatus() {
        Task {
            do {
                guard let userID = authSession.userID else { throw NetworkError.unauthorized }
                let response = try await affordabilitySource.getAffordabilityStatus(userID: userID)
                isAffordabilityCompleted = response.isStepCompleted
                completedSubject.send(response.isStepCompleted)
            } catch {
                completedSubject.send(false)
                self.error = error
            }
        }
    }

    @MainActor
    func checkCurrentState() async {
        do {
            guard let userID = authSession.userID else { throw NetworkError.unauthorized }
            try await userSource.getUserStatus(userID: userID)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func confirmCategorisation() async {
        do {
            guard let userID = authSession.userID else { throw NetworkError.unauthorized }
            try await transactionsSource.confirmSpendingCategories(userID: userID)
            await checkCurrentState()
            getAffordabilityStatus()
        } catch {
            self.error = error
        }
    }
}
