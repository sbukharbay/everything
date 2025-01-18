//
//  DashboardSettingsViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 04/08/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import Foundation
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class DashboardSettingsViewModel {
    @Published var apiVersion: String = ""
    @Published var error: Error?
    
    let updateNameSubject = PassthroughSubject<Bool, Never>()
    var firstName: String = "User"
    var lastName: String = "Name"
    var incomeData: IncomeStatusDataModel?
    let settingsData: [DashboardSettingsModel]
    let tableData: [String]
    private var apiVersionSource: APIVersionSource
    private var userSource: UserSource
    var userSession: SessionType

    init(userSession: SessionType = Auth0Session.shared,
         apiVersionSource: APIVersionSource = APIVersionService(),
         userSource: UserSource = UserService()) {
        self.apiVersionSource = apiVersionSource
        self.userSource = userSource
        self.userSession = userSession

        settingsData = [
            DashboardSettingsModel(icon: "income", title: "Income"),
            DashboardSettingsModel(icon: "savings", title: "Savings"),
            DashboardSettingsModel(icon: "spending", title: "Spending"),
            DashboardSettingsModel(icon: "linked_accounts", title: "Link Bank Accounts"),
            DashboardSettingsModel(icon: "help_support", title: "Help & Support")
        ]
        tableData = [
            "Terms & Conditions",
            "Acknowledgements"
        ]
        
        if let firstName = userSession.user?.givenName, let lastName = userSession.user?.familyName {
            self.firstName = firstName
            self.lastName = lastName
        } else {
            Task {
                await getUserName()
            }
        }

        Task {
            await getApiVersion()
        }
    }

    @MainActor
    func getUserName() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await userSource.getUserDetails(userID: userID)
            firstName = response.firstName
            lastName = response.lastName
            updateNameSubject.send(true)
        } catch {
            self.error = error
        }
    }

    @MainActor
    func getApiVersion() async {
        do {
            let response = try await apiVersionSource.getApiVersionNumber()
            apiVersion = response.build.version
        } catch {
            self.error = error
        }
    }
    
    func cleanUserApp() {
        cleanNotifications()
        cleanAccountsDatabase()
        clearUserCredentials()
        userSession.userID = nil
    }
    
    /// Clean notifcations after logout
    private func cleanNotifications() {
        NotificationManager.shared.cleanCounterBadge()
    }
    
    /// Clean accounts data such as isOnboardingCategorisationDone
    private func cleanAccountsDatabase() {
        AccountsManager.shared.cleanDatabase()
    }
    
    private func clearUserCredentials() {
        userSession.clearCredentials()
    }
}
