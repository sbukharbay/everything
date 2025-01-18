//
//  TermsViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 13/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import FirebaseMessaging
import Foundation
import AffordIQAuth0
import AffordIQNetworkKit
import Combine

class TermsViewModel {
    @Published var error: Error?
    @Published var nextStep: OnboardingStep?

    let userSession: SessionType
    let notificationSource: NotificationSource
    let userSource: UserSource
    var userID: String?

    init(userSession: SessionType = Auth0Session.shared,
         notificationSource: NotificationSource = NotificationService(),
         userSource: UserSource = UserService()) {
        self.userSession = userSession
        self.notificationSource = notificationSource
        self.userSource = userSource

        Task {
            await getUserID()
            await registerDevice()
        }
    }
    
    func getUserID() async {
        if let userID = userSession.userID {
            self.userID = userID
        } else if let externalUserID = userSession.user?.externalUserId {
            userID = await getUserID(with: externalUserID)
        }
    }

    func getUserID(with externalUserID: String) async -> String? {
        do {
            let response = try await userSource.getUserID(externalID: externalUserID)
            return response.userID
        } catch {
            self.error = error
            
            return nil
        }
    }
    
    func registerDevice() async {
        do {
            guard let id = userID,
                  let deviceID = await UIDevice.current.identifierForVendor?.uuidString
            else { throw NetworkError.badID }
            
            let fcmToken = Messaging.messaging().fcmToken ?? ""
            
            let model = RMRegisterDevice(deviceID: deviceID, token: fcmToken)
            
            try await notificationSource.registerDevice(userID: id, model: model)
        } catch {
            self.error = error
        }
    }

    @MainActor
    func setUserAgree() async {
        do {
            guard let userID = userID else { throw NetworkError.unauthorized }
            
            let model = RMTerms(userID: userID, date: Date().asStringFullDate(), version: "1.0")
            try await userSource.setUserAgree(model: model)
            
            Amplitude.instance().logEvent(OnboardingStep.acceptTerms.rawValue)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func checkCurrentState() async {
        do {
            guard let id = userID else { throw NetworkError.unauthorized }
            
            let response = try await userSource.getUserStatus(userID: id)
            nextStep = response.nextStep
        } catch {
            self.error = error
        }
    }
}
