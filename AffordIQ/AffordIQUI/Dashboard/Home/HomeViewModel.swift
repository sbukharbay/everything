//
//  HomeViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

class HomeViewModel {
    var userName: String = "Home"
    var leftToSpend: MonetaryAmount = .init(amount: 0)
    var savingsGoal: String = ""
    var styles: AppStyles
    private let spendingSource: SpendingSource
    private let accountsSource: AccountsSource
    private let affordabilitySource: AffordabilitySource
    private let userSource: UserSource
    private var userSession: SessionType
    var accountsAndConsents: [[InstitutionAccount]] = []
    
    @Published var error: Error?
    @Published var updateBottom: HomeModel?
    @Published var updateTop: PropertyGoalAndMortgageLimitsResponse?
    @Published var updateTitle: Bool?
    @Published var reconsent: Bool = false
    
    var progressBarAmount: Float {
        (updateTop?.mortgageLimits?.currentDeposit.amount?.floatValue ?? 0) / (updateTop?.targetDeposit?.amount?.floatValue ?? 1)
    }
    
    init(userSource: UserSource = UserService(),
         spendingSource: SpendingSource = SpendingService(),
         accountsSource: AccountsSource = AccountsService(),
         affordabilitySource: AffordabilitySource = AffordabilityService(),
         userSession: SessionType = Auth0Session.shared,
         styles: AppStyles = AppStyles.shared) {
        self.userSource = userSource
        self.userSession = userSession
        self.styles = styles
        self.spendingSource = spendingSource
        self.accountsSource = accountsSource
        self.affordabilitySource = affordabilitySource

        if let name = userSession.user?.givenName {
            userName = name
        }
        
        Task {
            await checkConsent()
        }

        resume()
    }

    func resume() {
        guard let id = userSession.userID else { return }
        
        Task {
            await getUserName()
            await getMonthlySpending(id)
            await mortgageAffordability(id)
        }
    }
    
    @MainActor
    func checkConsent() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await accountsSource.getAccounts(userID: userID)
            let period = Calendar.current.date(byAdding: .day, value: 21, to: Date())
            let uniqueAccounts = Array(Set(response.institutionAccounts)).sorted()
            
            accountsAndConsents = []
            
            response.openBankingConsents?.forEach { consent in
                if let period, consent.consentExpires <= period {
                    var bankAccounts = [InstitutionAccount]()
                    
                    uniqueAccounts.forEach { account in
                        if consent.providerId == account.institutionId {
                            var accountWithConsent = account
                            accountWithConsent.consent = consent
                            bankAccounts.append(accountWithConsent)
                        }
                    }
                    
                    if !bankAccounts.isEmpty {
                        accountsAndConsents.append(bankAccounts)
                    }
                }
            }
            
            if !accountsAndConsents.isEmpty {
                if let data = UserDefaults.standard.object(forKey: StorageKey.reconsentSkipped.key) as? Data,
                   let accounts = try? JSONDecoder().decode([[InstitutionAccount]].self, from: data) {
                    
                    if accountsAndConsents.count == accounts.count {
                        var ifSameConsent = [Bool]()

                        accountsAndConsents.forEach { bank1 in
                            accounts.forEach { bank2 in
                                if bank1.first?.institutionId == bank2.first?.institutionId {
                                    ifSameConsent.append(bank1.first?.consent?.consentExpires == bank2.first?.consent?.consentExpires)
                                }
                            }
                        }

                        if ifSameConsent.allSatisfy({ $0 == true }) {
                            return
                        }
                    }
                }
                
                reconsent = true
            }
        } catch {}
    }
    
    @MainActor
    func getMonthlySpending(_ id: String) async {
        do {
            let spending = try await spendingSource.getMonthlySpending(userID: id)
            
            leftToSpend = spending.discretionary.leftToSpend
            budgetCalculations(spending.discretionary)
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func mortgageAffordability(_ id: String) async {
        do {
            let affordability = try await affordabilitySource.getGoalTrackingAndMortgageLimits(userID: id)
            
            savingsGoal = affordability.savingsGoal?.monthlySavingsAmount?.shortDescription ?? "N/A"
            updateTop = affordability
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func getUserName() async {
        guard let id = userSession.userID else { return }
        
        do {
            let user = try await userSource.getUserDetails(userID: id)
            
            userName = user.firstName
            updateTitle = true
        } catch {
            self.error = error
        }
    }

    func budgetCalculations(_ response: DiscretionaryMonthlyBudgetResponse) {
        var infoText = ""
        var isOverSpend = false
        var alertMessage = NSMutableAttributedString()

        switch response.pattern {
        case .break:
            infoText = "✋ You are on track to break your budget this month."
            alertMessage = NSMutableAttributedString()
                .style("We estimate that you have ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(leftToSpend.shortDescription, font: styles.fonts.sansSerif.subheadline.bold)
                .style(" left to spend this month on groceries and non-essential expenses, while still reaching your savings goal of ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(savingsGoal, font: styles.fonts.sansSerif.subheadline.bold)
                .style(".\n\n", font: styles.fonts.sansSerif.subheadline.regular)
                .style("Note:\n", font: styles.fonts.sansSerif.subheadline.bold)
                .style("This is just an estimate based on your average living costs and monthly income. ", font: styles.fonts.sansSerif.subheadline.regular)
                .style("If your living costs this month are higher than average, or your income is lower than expected you may not reach your savings goal even if you spend within budget.",
                       font: styles.fonts.sansSerif.subheadline.regular)
        case .meet:
            infoText = "👍 You are on track to meet your budget this month."
            alertMessage = NSMutableAttributedString()
                .style("We estimate that you have ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(leftToSpend.shortDescription, font: styles.fonts.sansSerif.subheadline.bold)
                .style(" left to spend this month on groceries and non-essential expenses, while still reaching your savings goal of ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(savingsGoal, font: styles.fonts.sansSerif.subheadline.bold)
                .style(".\n\n", font: styles.fonts.sansSerif.subheadline.regular)
                .style("Note:\n", font: styles.fonts.sansSerif.subheadline.bold)
                .style("This is just an estimate based on your average living costs and monthly income. ", font: styles.fonts.sansSerif.subheadline.regular)
                .style("If your living costs this month are higher than average, or your income is lower than expected you may not reach your savings goal even if you spend within budget.",
                       font: styles.fonts.sansSerif.subheadline.regular)
        case .exceeded:
            infoText = "🙁 You have exceeded your budget for this month. This may effect the time it takes to complete your goal."
            isOverSpend = true
            alertMessage = NSMutableAttributedString()
                .style("You have spent ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(leftToSpend.shortDescriptionNoSign, font: styles.fonts.sansSerif.subheadline.bold)
                .style(" over your monthly budget for groceries and non-essential expenses. As a result you may not reach your savings goal of ", font: styles.fonts.sansSerif.subheadline.regular)
                .style(savingsGoal, font: styles.fonts.sansSerif.subheadline.bold)
                .style(".\n\n", font: styles.fonts.sansSerif.subheadline.regular)
                .style("Note:\n", font: styles.fonts.sansSerif.subheadline.bold)
                .style("This is just an estimate based on your average living costs and monthly income. ", font: styles.fonts.sansSerif.subheadline.regular)
                .style("If your living costs this month are higher than average, or your income is lower than expected you may not reach your savings goal even if you spend within budget.",
                       font: styles.fonts.sansSerif.subheadline.regular)
        }

        updateBottom = HomeModel(info: infoText, isOverSpend: isOverSpend, leftToSpend: response.leftToSpend, message: alertMessage)
    }
}
