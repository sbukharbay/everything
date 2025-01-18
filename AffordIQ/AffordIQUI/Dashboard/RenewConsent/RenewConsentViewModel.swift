//
//  RenewConsentViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 31.07.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Combine
import AffordIQNetworkKit
import AffordIQAuth0
import AffordIQFoundation

class RenewConsentViewModel {
    @Published var reconsent: ReconsentRequestModel?
    
    var accounts: [[InstitutionAccount]]
    var renew: [Bool]
    
    private var session: SessionType
    var preReconsentType: PreReconsentType
    
    init(accounts: [[InstitutionAccount]], session: SessionType = Auth0Session.shared, type: PreReconsentType) {
        self.accounts = accounts
        self.session = session
        self.preReconsentType = type
        self.renew = []
        
        accounts.forEach { _ in
            self.renew.append(true)
        }
    }

    func confirm() {
        var providers = [ReconsentProvider]()
        accounts.enumerated().forEach { index, item in
            guard let id = item.first?.institutionId else { return }
            providers.append(ReconsentProvider(provider: id, renew: renew[index]))
        }
        reconsent = ReconsentRequestModel(providers: providers)
    }
}
