//
//  FeedbackFormViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 28.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import AffordIQNetworkKit
import AffordIQAuth0
import Amplitude
import Combine

struct FeedbackReasonModel: Equatable {
    var reason: String
    var selected: Bool
}

class FeedbackFormViewModel {
    @Published var showError: Bool = false
    @Published var isCompleted: Bool = false
    @Published var error: Error?
    
    let network: FeedbackSource
    let className: String
    let session: SessionType
    let userSource: UserSource
    var fullName: String?
    var email: String?
    
    var reasons: [FeedbackReasonModel] = [
        FeedbackReasonModel(reason: "It doesn't work", selected: false),
        FeedbackReasonModel(reason: "I don't know what to do", selected: false),
        FeedbackReasonModel(reason: "I don't like something", selected: false),
        FeedbackReasonModel(reason: "I really like something", selected: false),
        FeedbackReasonModel(reason: "Other", selected: false)
    ]

    init(networkSource: FeedbackSource = FeedbackService(),
         session: SessionType = Auth0Session.shared,
         className: String,
         userSource: UserSource = UserService()) {
        self.network = networkSource
        self.className = className
        self.session = session
        self.userSource = userSource
        
        if let user = session.user {
            self.fullName = user.fullName
            self.email = user.name
        } else {
            Task {
                await getUser()
            }
        }
    }

    func submit(comment: String) async {
        do {
            let model = try getRMFeedback(comment: comment)
            
            try await network.submitFeedback(model)
            isCompleted = true
        } catch let error {
            self.error = error
            print(error)
        }
    }
    
    @MainActor
    func getUser() async {
        do {
            guard let userID = session.userID else { throw AuthError.missingToken }
            let user: UserRegistrationData = try await userSource.getUserDetails(userID: userID)
            self.fullName = user.firstName + " " + user.lastName
            self.email = user.username
        } catch let error {
            self.error = error
        }
    }
    
    func getRMFeedback(comment: String) throws -> RMFeedback {
        guard let fullName, let email else { throw NetworkError.emptyObject }
        guard let choosed = reasons.first(where: { $0.selected }) else {
            showError = true
            throw NetworkError.emptyObject
        }
        guard !comment.isEmpty else { throw NetworkError.emptyObject }
        
        let version = "App version: " + getApplicationVersion() + ". Device: " + UIDevice.modelName + ". System: iOS " + UIDevice.current.systemVersion + "."
        
        let model = RMFeedback(name: fullName,
                               // TODO: renaming
                               // Don't have idea why user.name takes email. Need to refactor.
                               // But user.email is empty
                               email: email,
                               comment: comment,
                               screenName: className,
                               reason: choosed.reason,
                               appVersion: version)
        
        return model
    }

    func getApplicationVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? NSLocalizedString("Unknown Version", bundle: uiBundle, comment: "Unknown Version")
    }
}
