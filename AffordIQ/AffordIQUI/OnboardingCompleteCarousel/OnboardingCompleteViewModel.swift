//
//  OnboardingCompleteViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/03/2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Amplitude
import UIKit
import AffordIQFoundation
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class OnboardingCompleteViewModel {
    @Published var error: Error?
    
    let moveToDashboardSubject = PassthroughSubject<Bool, Never>()
    let pages: [String]
    
    private let userSource: UserSource
    private let userSession: SessionType
    private let amplitude: AmplitudeProtocol

    init(userSource: UserSource = UserService(),
         authSession: SessionType = Auth0Session.shared,
         amplitude: AmplitudeProtocol = Amplitude.instance()
    ) {
        self.userSource = userSource
        self.userSession = authSession
        self.amplitude = amplitude
        
        pages = [
            "The first part of your beta mission has been completed and Lotus can now head back to the future. Don't worry because Lotus will still be in contact as you complete the next stage of your mission.",
            "The testing and feedback you have provided is invaluable to Lotus's greater objective to save us from a future where home ownership is unaffordable.",
            "We thank you and wish you good luck with the next stage of your mission. Remember Lotus will still be in contact, helping you stay on budget and on track towards owning your home."
        ]
    }
    
    func showDashboard() async {
        do {
            try await completeOnboarding()
            moveToDashboardSubject.send(true)
        } catch {
            self.error = error
        }
    }
    
    func completeOnboarding() async throws {
        guard let userID = userSession.userID else { throw NetworkError.unauthorized }
        try await userSource.completeOnboarding(userID: userID)
    }
    
    func logEvent(key: String) {
        amplitude.logEvent(key: key)
    }
}
