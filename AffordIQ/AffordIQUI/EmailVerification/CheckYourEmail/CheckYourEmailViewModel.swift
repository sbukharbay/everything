//
//  CheckYourEmailViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 01.12.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import Foundation
import AffordIQAuth0
import AffordIQNetworkKit

class CheckYourEmailViewModel {
    var registrationData: UserRegistrationData
    private var session: SessionType
    private var userSource: UserSource
    private let loginSource: LoginSource
    
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var showTermsView: Bool = false
    @Published var showError: Bool = false
    @Published var showNext: Bool = false
    
    init(session: SessionType = Auth0Session.shared,
         data: UserRegistrationData,
         userSource: UserSource = UserService(),
         loginSource: LoginSource = LoginService()) {
        self.registrationData = data
        self.session = session
        self.userSource = userSource
        self.loginSource = loginSource
    }

    @MainActor
    func getUserId() async {
        if let userId = session.userID {
            await checkIfEmailConfirmed(userID: userId)
        }
    }

    @MainActor
    func emailConfirmed() async {
        isLoading = true
        if let userID = session.userID {
            await checkIfEmailConfirmed(userID: userID)
        } else {
            await getToken()
        }
        isLoading = false
    }
    
    @MainActor
    func getToken() async {
        let model = RMFetchToken(
            clientId: Environment.shared.sessionConfiguration.webClientId,
            clientSecret: Environment.shared.sessionConfiguration.webClientSecret,
            audience: Environment.shared.sessionConfiguration.audienceUri,
            grantType: Environment.shared.sessionConfiguration.webGrantType)
        do {
            self.session.token = try await loginSource.fetchToken(model)
            await self.getUserId()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func checkIfEmailConfirmed(userID: String) async {
        Amplitude.instance().setUserId(userID)
        
        do {
            let response = try await userSource.getAuth0User(userID: userID)
            if response.emailVerified {
                await checkCurrentState(id: userID)
            } else {
                showError = true
            }
        } catch {
            self.error = error
        }
    }

    @MainActor
    func checkCurrentState(id: String) async {
        do {
            let response = try await userSource.getUserStatus(userID: id)
            switch response.nextStep {
            case .acceptTerms:
                Amplitude.instance().logEvent(OnboardingStep.verifyEmailAddress.rawValue)
                showTermsView = true
            default:
                showNext = true
            }
        } catch {
            self.error = error
        }
    }
}
