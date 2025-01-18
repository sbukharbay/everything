//
//  RegistrationViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 23/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import UIKit
import AffordIQAuth0
import AffordIQControls
import AffordIQNetworkKit
import Combine

enum RegistrationViewField: CaseIterable {
    case givenName
    case familyName
    case mobileNumber
    case dateOfBirth
    case emailAddress
    case password
    case confirmPassword
}

enum RegistrationError: Error {
    case userAlreadyExists
    case registrationDataNil
}

extension RegistrationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userAlreadyExists:
            return NSLocalizedString("An account already exists for that email address.",
                                     bundle: uiBundle,
                                     comment: "An account already exists for that email address.")
        case .registrationDataNil:
            return NSLocalizedString("Registration data is empty",
                                     bundle: uiBundle,
                                     comment: "Something went wront!")
        }
    }
}

protocol RegistrationView: ViewController, Stylable, ErrorPresenter { }

class RegistrationViewModel: FormViewModel {
    typealias FieldType = RegistrationViewField
    
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var isDeleting: Bool = false
    @Published var isSendingData: Bool = false
    @Published var registrationData: UserRegistrationData?
    @Published var registrationError: String = ""
    
    let resetPasswordSubject = PassthroughSubject<Void, Error>()
    let deleteAccountSubject = PassthroughSubject<Void, Never>()
    let registrationSucceedSubject = PassthroughSubject<Void, Never>()
    let completeSubject = PassthroughSubject<Void, Never>()
    
    weak var view: RegistrationView?
    let passwordRules: PasswordRules
    
    private var userSource: UserSource
    var userSession: SessionType
    
    init(view: RegistrationView? = nil,
         userSource: UserSource = UserService(),
         userSession: SessionType = Auth0Session.shared,
         data: UserRegistrationData? = nil) {
        self.view = view
        self.userSource = userSource
        self.userSession = userSession
        
        passwordRules = PasswordRules(rules: [.required(.digits),
                                              .required(.upper),
                                              .required(.lower),
                                              .maxConsecutive(2),
                                              .minLength(8)])
        
        if let data {
            registrationData = data
        } else {
            Task {
                await getUserData()
            }
        }
    }
    
    @MainActor
    func getUserData() async {
        do {
            guard let userID = userSession.userID else { return }
            isLoading = true
            registrationData = try await userSource.getUserDetails(userID: userID)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    func textFieldShouldReturn(field: RegistrationViewField, messageSetters: [RegistrationViewField: MessageSetter], values: [RegistrationViewField: String]) -> Bool {
        let validationMessage = self.validationMessage(field: field, values: values)
        messageSetters[field]?(validationMessage)
        
        return true
    }
}

extension RegistrationViewModel {
    func submit(values: [RegistrationViewField: String]) {
        Task {
            let userModel = RMCreateUser(
                firstName: values[.givenName] ?? "",
                lastName: values[.familyName] ?? "",
                mobilePhone: values[.mobileNumber] ?? "",
                dateOfBirth: values[.dateOfBirth]?.asDate().asStringYYYYMMDD() ?? "",
                password: values[.password] ?? "",
                username: values[.emailAddress] ?? ""
            )
            
            await submit(userModel: userModel)
        }
    }
    
    func submit(userModel: RMCreateUser) async {
        isSendingData = true
        do {
            let checkForUsername = try await userSource.checkIfUsernameExists(username: userModel.username)
            
            guard !checkForUsername.exists else {
                throw RegistrationError.userAlreadyExists
            }
            
            let response = try await userSource.createUser(model: userModel)
            userSession.userID = response.userId
            
            registrationSucceeded(userModel: userModel)
        } catch {
            registrationError = error.localizedDescription
        }
        isSendingData = false
    }
    
    func saveFieldsResults(data: RMCreateUser) {
        registrationData = UserRegistrationData(dateOfBirth: data.dateOfBirth, firstName: data.firstName, lastName: data.lastName, mobilePhone: data.mobilePhone, username: data.username)
    }
    
    @MainActor func deleteAccount() async {
        isDeleting = true
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            try await userSource.deleteUser(userID: userID)
            deleteAccountSucceeded()
        } catch {
            self.error = error
        }
        isDeleting = false
    }
    
    func registrationSucceeded(userModel: RMCreateUser) {
        saveFieldsResults(data: userModel)
        userSession.clearCredentials()
        registrationSucceedSubject.send()
        
        Amplitude.instance().logEvent(OnboardingStep.createAccount.rawValue)
    }
    
    func deleteAccountSucceeded() {
        deleteAccountSubject.send()
        
        Amplitude.instance().logEvent("DELETED_ACCOUNT")
    }
    
    // TODO: - Need to test
    @MainActor
    func updateAccount(dateOfBirth: String, mobileNumber: String, familyName: String, givenName: String) async {
        let userID = userSession.userID ?? ""
        let model = RMPatchUser(
            dateOfBirth: dateOfBirth,
            firstName: givenName,
            lastName: familyName,
            mobilePhone: mobileNumber
        )
    
        do {
            try await userSource.updateUser(userID: userID, model: model)
            userSession.updateUserData()
            completeSubject.send()
        } catch {
            self.error = error
        }
    }
    
    // TODO: - Need to test
    @MainActor
    func resetPassword() async {
        do {
            guard let user = registrationData else { throw RegistrationError.registrationDataNil }
            
            try await userSession.resetPassword(email: user.username)
            resetPasswordSubject.send()
        } catch let error {
            resetPasswordSubject.send(completion: .failure(error))
        }
    }
}

// MARK: - Fields validation
extension RegistrationViewModel {
    func isValid(field: RegistrationViewField, values: [RegistrationViewField: String]) -> Bool {
        guard let value = values[field]?.sanitized,
              !value.isEmpty
        else {
            return false
        }
        
        switch field {
        case .givenName, .familyName:
            return isValidName(value)
            
        case .mobileNumber:
            return isValidPhoneNumber(value)
            
        case .emailAddress:
            return isValidEmail(value)
            
        case .password:
            return passwordRules.validate(password: value)
            
        case .confirmPassword:
            return value == values[.password]?.sanitized
            
        default:
            return true
        }
    }
    
    func validationMessage(field: RegistrationViewField, values: [RegistrationViewField: String]) -> String? {
        let isValid = self.isValid(field: field, values: values)
        
        switch field {
        case .givenName, .familyName:
            return isValid ? nil : getValidationMessage(for: field)
            
        case .mobileNumber:
            return isValid ? nil :
            NSLocalizedString("Please enter a valid phone number.",
                              bundle: uiBundle,
                              comment: "Please enter a valid phone number.")
        case .emailAddress:
            return isValid ? nil :
            NSLocalizedString("Please enter a valid email address.",
                              bundle: uiBundle,
                              comment: "Please enter a valid email address.")
        case .password:
            return isValid ? nil :
            NSLocalizedString("Please enter a valid password.",
                              bundle: uiBundle,
                              comment: "Please enter a valid password.")
        case .confirmPassword:
            return isValid ? nil :
            NSLocalizedString("The passwords do not match.",
                              bundle: uiBundle,
                              comment: "The passwords do not match.")
        default:
            return isValid ? nil :
            NSLocalizedString("Please enter a value.",
                              bundle: uiBundle,
                              comment: "Please enter a value.")
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPhoneNumber(_ number: String) -> Bool {
        let phoneNumberRegEx = "^(\\+44\\s?7\\d{3}|\\(?07\\d{3}\\)?)\\s?\\d{3}\\s?\\d{3}$"
        
        let phoneNumberPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegEx)
        return phoneNumberPredicate.evaluate(with: number)
    }
    
    func isValidName(_ name: String) -> Bool {
        return name.count >= 2 && name.count <= 35
    }
    
    func getValidationMessage(for field: RegistrationViewField) -> String {
        if field == .givenName {
            return NSLocalizedString(
                "Given name should be between 2 - 35 characters.",
                bundle: uiBundle,
                comment: "Please enter a value."
            )
        }
    
        return NSLocalizedString(
            "Family name should be between 2 - 35 characters.",
            bundle: uiBundle,
            comment: "Please enter a value."
        )
    }
}
