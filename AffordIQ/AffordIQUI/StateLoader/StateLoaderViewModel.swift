//
//  StateLoaderViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20.01.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import AffordIQAuth0
import FirebaseMessaging
import UIKit
import Amplitude
import AffordIQNetworkKit

class StateLoaderViewModel {
    @Published var error: Error?
    @Published var nextStep: OnboardingStep?
    @Published var presentFailed: Bool?
    
    var userData: UserRegistrationData?
    var session: SessionType
    private var userSource: UserSource = UserService()
    private var notificationSource: NotificationSource = NotificationService()
    
    init(session: SessionType = Auth0Session.shared) {
        self.session = session
    }

    @MainActor
    func login(from view: UIViewController) {
        try? session.authenticate(from: view, completion: { ok, _ in
            if ok {
                Task {
                    await self.getUserId()
                }
            } else {
                asyncIfRequired {
                    self.presentFailed = true
                }
            }
        })
    }
    
    @MainActor
    func getUserId() async {
        guard let externalId = session.user?.externalUserId else { return }

        do {
            let response = try await userSource.getUserID(externalID: externalId)
            if let userID = response.userID {
                self.session.userID = userID
                await self.checkCurrentState()
            }
        } catch {
            self.error = error
        }
    }

    @MainActor
    func checkCurrentState() async {
        guard let userID = session.userID else { return }
        
        do {
            let response = try await userSource.getUserStatus(userID: userID)
            await self.registerDevice()
            
            if response.nextStep == .verifyEmailAddress {
                await getUserData()
            }
            self.nextStep = response.nextStep
            
            Amplitude.instance().logEvent("LOGGED_IN", withEventProperties: ["NEXT_STEP": response.nextStep.rawValue])
        } catch {
            self.error = error
        }
    }

    @MainActor
    func registerDevice() async {
        guard let userID = session.userID else { return }
        
        Amplitude.instance().setUserId(userID)
        
        guard let fcmToken = Messaging.messaging().fcmToken,
                let deviceID = UIDevice.current.identifierForVendor?.uuidString
        else { return }

        let data = RMRegisterDevice(deviceID: deviceID, token: fcmToken)
        
        do {
            try await notificationSource.registerDevice(userID: userID, model: data)
        } catch {
            self.error = error
        }
    }

    @MainActor
    func getUserData() async {
        do {
            guard let userID = session.userID else { throw NetworkError.unauthorized }
            let response = try await userSource.getUserDetails(userID: userID)
            userData = response
        } catch {
            self.error = error
        }
    }
}
