//
//  LinkAccountsViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 14.06.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import Combine
import AffordIQFoundation
import AffordIQAuth0
import AffordIQNetworkKit
import AffordIQControls

class LinkAccountsViewModel: NSObject {
    @Published var accountsLinked: Bool?
    @Published var accountsExists: Bool?
    @Published var error: Error?
    
    var institutionID: String
    var currentlyLinkedAccounts: [InstitutionAccount] = []
    var isDashboard: Bool = false
    var getStartedType: GetStartedViewType?
    
    private let userSession: SessionType
    private let accountsSource: AccountsSource
    
    init(institutionID: String,
         userSession: SessionType = Auth0Session.shared,
         accountsSource: AccountsSource = AccountsService(),
         isDashboard: Bool,
         getStartedType: GetStartedViewType?) {
        self.institutionID = institutionID
        self.userSession = userSession
        self.accountsSource = accountsSource
        self.isDashboard = isDashboard
        self.getStartedType = getStartedType
        super.init()
        
        Task {
            await getAccounts()
        }
    }
    
    @MainActor
    func getAccounts() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await accountsSource.getAccounts(userID: userID)
            currentlyLinkedAccounts = response.institutionAccounts.filter { $0.institutionId == institutionID }.sorted()
            
            accountsExists = true
        } catch {
            print(error)
        }
    }
    
    @MainActor
    func linkAccounts(linkInstitutionID: String, linkAccounts: [InstitutionAccount]) async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let accountsToLink = linkAccounts.map { $0.accountId }
            let accountsRequest = RMLinkAccounts(accountInstitutionID: linkInstitutionID, accountsToLink: accountsToLink, userID: userID)
            
            let response = try await accountsSource.link(model: accountsRequest)
            
            if response.statusCode == 201 {
                accountsLinked = true
            }
        } catch {
            self.error = error
        }
    }
}
