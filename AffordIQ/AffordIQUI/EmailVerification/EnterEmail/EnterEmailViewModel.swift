//
//  EnterEmailViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 30.11.2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import AffordIQControls
import AffordIQAuth0
import AffordIQNetworkKit

enum EmailViewField: CaseIterable {
    case email
}

class EnterEmailViewModel: FormViewModel {
    typealias FieldType = EmailViewField

    var registrationData: UserRegistrationData?
    var email: String
    private var session: SessionType
    private var userSource: UserSource
    private let loginSource: LoginSource
    
    @Published var error: Error?
    @Published var userAlreadyExists: Bool = false
    @Published var showNext: Bool = false
    @Published var showCustomError: Bool = false
    
    init(
        session: SessionType = Auth0Session.shared,
        userSource: UserSource = UserService(),
        loginSource: LoginSource = LoginService(),
        data: UserRegistrationData?
    ) {
        self.session = session
        self.userSource = userSource
        self.loginSource = loginSource
        registrationData = data
        email = ""
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}

extension EnterEmailViewModel {
    func textFieldShouldReturn(field: EmailViewField, messageSetters: [EmailViewField: MessageSetter], values: [EmailViewField: String]) -> Bool {
        let isValid = self.isValid(field: field, values: values)
        let validationMessage = self.validationMessage(field: field, values: values)

        messageSetters[field]?(validationMessage)

        switch field {
        case .email:
            return isValid
        }
    }

    func isValid(field: EmailViewField, values: [EmailViewField: String]) -> Bool {
        guard let value = values[field]?.sanitized, !value.isEmpty else {
            return false
        }

        switch field {
        case .email:
            return isValidEmail(value)
        }
    }

    func validationMessage(field: EmailViewField, values: [EmailViewField: String]) -> String? {
        let isValid = self.isValid(field: field, values: values)

        switch field {
        case .email:
            return isValid ? nil :
                NSLocalizedString("Please enter a valid email address.",
                                  bundle: uiBundle,
                                  comment: "Please enter a valid email address.")
        }
    }

    func submit(values: [EmailViewField: String]) {
        if !isValid(values: values) || values.isEmpty {
            showCustomError = true
            return
        }
        
        registrationData?.username = values[.email] ?? ""
        email = values[.email] ?? ""

        Task {
            if let userID = session.userID, !userID.contains("auth0|") {
                await updateUserEmail(userID: userID)
            } else {
                await getToken()
            }
        }
    }
    
    @MainActor
    func getToken(
        model: RMFetchToken = RMFetchToken(
            clientId: Environment.shared.sessionConfiguration.webClientId,
            clientSecret: Environment.shared.sessionConfiguration.webClientSecret,
            audience: Environment.shared.sessionConfiguration.audienceUri,
            grantType: Environment.shared.sessionConfiguration.webGrantType
        )
    ) async {
        do {
            self.session.token = try await loginSource.fetchToken(model)
            await self.checkUserID()
        } catch {
            self.error = error
        }
    }

    // TODO: - need to test
    @MainActor
    func checkUserID() async {
        guard let userID = session.userID else { return }
        
        if userID.contains("auth0"), let externalId = userID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) {
            await getUserID(externalId)
        } else {
            await self.updateUserEmail(userID: userID)
        }
    }
    
    @MainActor
    func getUserID(_ externalID: String) async {
        do {
            let response = try await userSource.getUserID(externalID: externalID)
            if let userID = response.userID {
                self.session.userID = userID
                await self.updateUserEmail(userID: userID)
            }
        } catch {
            self.error = error
        }
    }

    @MainActor
    func updateUserEmail(userID: String) async {
        let model = RMPatchUser(username: email)
        
        do {
            let response = try await userSource.checkIfUsernameExists(username: email)
            if !response.exists {
                try await userSource.updateUser(userID: userID, model: model)
                showNext = true
            } else {
                userAlreadyExists = true
            }
        } catch {
            self.error = error
        }
    }
}
