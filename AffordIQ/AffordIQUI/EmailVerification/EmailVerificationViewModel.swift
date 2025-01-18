//
//  EmailVerificationViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import Foundation
import AffordIQAuth0
import AffordIQNetworkKit

class EmailVerificationViewModel {
    var registrationData: UserRegistrationData
    private let session: SessionType
    private let userSource: UserSource
    private let loginSource: LoginSource
    
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var showCheckEmailView: Bool = false
    @Published var showTermsView: Bool = false
    @Published var showNext: Bool = false
    
    init(session: SessionType = Auth0Session.shared,
         userSource: UserSource = UserService(),
         loginSource: LoginSource = LoginService(),
         data: UserRegistrationData) {
        self.registrationData = data
        self.session = session
        self.userSource = userSource
        self.loginSource = loginSource
    }

    @MainActor
    func emailConfirmed() async {
        isLoading = true
        if let userID = session.userID, !userID.contains("auth0|") {
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
            await self.checkUserID()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func checkUserID() async {
        if let userID = session.userID, !userID.contains("auth0|") {
            await checkIfEmailConfirmed(userID: userID)
        } else if let id = session.userID {
            if id.contains("auth0"), let externalId = id.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
                await getUserID(externalId)
            } else {
                await self.checkIfEmailConfirmed(userID: id)
            }
        }
    }

    @MainActor
    func getUserID(_ externalID: String) async {
        do {
            let response = try await userSource.getUserID(externalID: externalID)
            if let userID = response.userID {
                self.session.userID = userID
                await self.checkIfEmailConfirmed(userID: userID)
            }
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
                showCheckEmailView = true
            }
        } catch {
            print(error)
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
