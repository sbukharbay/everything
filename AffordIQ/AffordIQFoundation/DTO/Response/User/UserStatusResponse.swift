//
//  UserStatusResponse.swift
//  AffordIQNetworkKit
//
//  Created by Sultangazy Bukharbay on 26/06/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public struct UserStatusResponse: Response {
    public let description: String?
    public let errors: [String]?
    public let message: String?
    public let statusCode: Int
    public let email: String?
    public let nextStep: OnboardingStep
    
    enum CodingKeys: String, CodingKey {
        case description
        case errors
        case message
        case statusCode = "status_code"
        case email
        case nextStep = "next_step"
    }
    
    public init(description: String?, errors: [String]?, message: String?, statusCode: Int, email: String?, nextStep: OnboardingStep) {
        self.description = description
        self.errors = errors
        self.message = message
        self.statusCode = statusCode
        self.email = email
        self.nextStep = nextStep
    }
}

public enum OnboardingStep: String, Codable {
    case acceptTerms = "ACCEPT_TS_AND_CS"
    case addIncomeInfo = "ADD_INCOME_INFORMATION"
    case addSavingsInfo = "ADD_SAVINGS_INFORMATION"
    case completeOnboarding = "COMPLETE_ONBOARDING"
    case completeTransactionProcessing = "COMPLETE_TRANSACTION_PROCESSING"
    case completeBudget = "COMPLETE_BUDGET"
    case createAccount = "CREATE_ACCOUNT"
    case linkBankAccounts = "LINK_BANK_ACCOUNTS"
    case setAffordability = "SET_AFFORDABILITY"
    case setDepositGoal = "SET_DEPOSIT_GOAL"
    case setPropertyGoal = "SET_PROPERTY_GOAL"
    case setSavingsGoal = "SET_SAVINGS_GOAL"
    case validateSpending = "VALIDATE_SPENDING"
    case verifyEmailAddress = "VERIFY_EMAIL_ADDRESS"
    case showDashboard = "SHOW_DASHBOARD"
    
    public var isAfterCompleteTransactionProcessing: Bool {
        switch self {
        case .completeTransactionProcessing,
             .completeOnboarding,
             .setSavingsGoal,
             .setPropertyGoal,
             .setDepositGoal,
             .completeBudget,
             .showDashboard,
             .setAffordability:
            return true
        case .validateSpending,
             .addSavingsInfo,
             .linkBankAccounts,
             .acceptTerms,
             .verifyEmailAddress,
             .createAccount,
             .addIncomeInfo:
            return false
        }
    }
}
