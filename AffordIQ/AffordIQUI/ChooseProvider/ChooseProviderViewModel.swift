//
//  ChooseProviderViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import AffordIQNetworkKit
import AffordIQAuth0

class ChooseProviderViewModel {
    var providers: [Provider]
    var addedSavings: Bool?
    var isSettings: Bool = false
    private var openBankingSource: OpenBankingSource
    private var accountsSource: AccountsSource
    
    @Published var presentProviders: ([Provider], Bool)?
    @Published var selectFrom: ([InstitutionAccount], String)?
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    var checkAttempts: Int = 0
    
    private var userSession: SessionType
    var getStartedType: GetStartedViewType?
    
    init(addedSavings: Bool? = nil,
         isSettings: Bool = false,
         openBankingSource: OpenBankingSource = OpenBankingService(),
         accountsSource: AccountsSource = AccountsService(),
         userSession: SessionType = Auth0Session.shared,
         getStartedType: GetStartedViewType?
    ) {
        self.addedSavings = addedSavings
        self.isSettings = isSettings
        self.openBankingSource = openBankingSource
        self.accountsSource = accountsSource
        self.userSession = userSession
        self.getStartedType = getStartedType
        self.providers = []
        presentProviders = (providers, false)

        Task {
            isLoading = true
            await getProviders()
            isLoading = false
        }
    }

    @MainActor
    func getProviders() async {
        do {
            let response = try await openBankingSource.getProviders()
            providers = response.sorted()
            presentProviders = (providers, false)
        } catch let error {
            self.error = error
        }
    }

    func setAuthorised(request: RMAuthoriseBank, institutionID: String) async {
        guard !request.code.isEmpty else { return }
        isLoading = true
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let query = RMAuthoriseBank(code: request.code, scope: request.scope, state: request.state, providerID: institutionID)
            try await openBankingSource.authoriseCode(body: query)
            await checkAuthStatus(of: userID, institutionID: institutionID)
            await getAccounts(institutionID)
        } catch let error {
            self.error = error
        }
        isLoading = false
    }
    
    func checkAuthStatus(of userID: String, institutionID: String) async {
        do {
            let response = try await openBankingSource.checkAuthStatus(of: userID)
            if !response.isAuthorisationComplete || response.institutionID != institutionID {
                throw AffordIQError.openBankingAuthorisationNotComplete
            }
        } catch {
            if checkAttempts < 3 {
                checkAttempts += 1
                sleep(2)
                await checkAuthStatus(of: userID, institutionID: institutionID)
            } else {
                self.error = error
            }
        }
    }

    func getAccounts(_ institutionID: String) async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await accountsSource.getInstitutionAccounts(userID: userID, institutionID: institutionID)
            guard let accounts = response.institutionAccounts else { return }
            selectFrom = (accounts, institutionID)
        } catch let error {
            self.error = error
        }
    }

    func filter(with filter: String?) {
        presentProviders = (search(for: filter, in: providers), true)
    }
}

extension Provider: Searchable {
    public var searchFields: [String] {
        return [displayName]
    }
}
