//
//  ReconsentProcessingViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 01.08.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import AffordIQFoundation
import AffordIQAuth0
import AffordIQNetworkKit
import AffordIQControls

class ReconsentProcessingViewModel {
    @Published var error: Bool?
    @Published var manualRenew: Bool?
    @Published var successReconsent: String?
    @Published var noDates: Bool?
    
    var providers: ReconsentRequestModel
    private var session: SessionType
    private var openBankingSource: OpenBankingSource
    private var accountsSource: AccountsSource
    var trueLayerResponse: [TrueLayerModel]?
    var preReconsentType: PreReconsentType
    
    init(providers: ReconsentRequestModel, session: SessionType = Auth0Session.shared, openBankingSource: OpenBankingSource = OpenBankingService(), accountsSource: AccountsSource = AccountsService(), type: PreReconsentType) {
        self.providers = providers
        self.session = session
        self.preReconsentType = type
        self.openBankingSource = openBankingSource
        self.accountsSource = accountsSource
        
        Task {
            await reconsent()
        }
    }

    @MainActor
    func reconsent() async {
        do {
            guard let userID = session.userID else { throw NetworkError.unauthorized }
            let response = try await openBankingSource.reconsent(userID: userID, providers: providers)
            trueLayerResponse = response.trueLayerResponse
            
            if let trueLayer = response.trueLayerResponse {
                trueLayer.enumerated().forEach({ index, trueLayer in
                    if trueLayer.response.actionNeeded == .none {
                        trueLayerResponse?.remove(at: index)
                    }
                })
                
                next()
            } else {
                error = true
            }
        } catch {
            self.error = true
        }
    }
    
    private func next() {
        if let trueLayerResponse, !trueLayerResponse.isEmpty {
            manualRenew = true
        } else {
            Task {
                await getAccountsDates()
            }
        }
    }
    
    func reconsentNext() {
        trueLayerResponse?.removeFirst()
        next()
    }
    
    func setAuthorised(request: RMAuthoriseBank, id: String) async {
        do {
            guard !request.code.isEmpty else { throw NetworkError.emptyObject }
            
            let query = RMAuthoriseBank(code: request.code, scope: request.scope, state: request.state, providerID: id)
            try await openBankingSource.authoriseCode(body: query)
            reconsentNext()
        } catch {
            self.error = true
        }
    }
    
    func skip() {
        trueLayerResponse?.removeFirst()
        
        if let trueLayerResponse, !trueLayerResponse.isEmpty {
            manualRenew = true
        } else {
            noDates = true
        }
    }
    
    @MainActor
    func getAccountsDates() async {
        do {
            guard let userID = session.userID else { throw NetworkError.unauthorized }
            let response = try await accountsSource.getAccounts(userID: userID)
            var dates = ""
            
            response.openBankingConsents?.forEach { consent in
                providers.providers.forEach { bank in
                    if bank.provider == consent.providerId {
                        dates += "\n" + bank.provider.capitalizedFirstLetter + " until " + consent.consentExpires.asStringFullMonth()
                    }
                }
            }
            
            if !dates.isEmpty {
                successReconsent = dates
            } else {
                noConsent()
            }
        } catch {
            self.noConsent()
        }
    }
    
    func noConsent() {
        BusyView.shared.hide(success: false)
        noDates = true
    }
}

public enum PreReconsentType {
    case accounts
    case accountDetails
    case reconsent
}
