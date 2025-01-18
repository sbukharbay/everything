//
//  AffordIQNavigator+Pages.swift
//  AffordIQUITests
//
//  Created by Simon Lawrence on 05/01/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

extension AffordIQNavigator {
    enum OverlayView: String {
        case overlay = "Overlay"
        case button = "Overlay.Button"
    }

    enum HomePage: String {
        case page = "Home"
        case settings = "Home.Settings"
    }

    enum SettingsPage: String {
        case page = "Settings"
        case acknowlegements = "Settings.Acknowlegements"
        case logout = "Settings.Logout"
        case name = "Settings.Name"
        case username = "Settings.Username"
    }

    enum TransactionsPage: String {
        case page = "Transactions"
    }

    enum AffordabilityPage: String {
        case page = "Affordability"
        case affordablePropertyValue = "Affordability.AffordablePropertyValue"
        case deposit = "Affordability.Deposit"
        case spending = "Affordability.Spending"
        case income = "Affordability.Income"
    }

    enum DepositPage: String {
        case page = "Deposit"
        case edit = "Deposit.Edit"
        case addOutsideCapital = "Deposit.AddOutsideCapital"
    }

    enum AccountDetailsPage: String {
        case page = "AccountDetails"
        case renew = "AccountDetails.Renew"
        case disconnect = "AccountDetails.Disconnect"
    }

    enum OutsideCapitalPage: String {
        case page = "OutsideCapital"
        case amount = "OutsideCapital.Amount"
        case description = "OutsideCapital.Description"
        case apply = "OutsideCapital.Apply"
        case cancel = "OutsideCapital.Cancel"
    }

    enum IncomePage: String {
        case page = "Income"
        case earnings = "Income.Earnings"
        case cancel = "Income.Cancel"
        case saveChanges = "Income.SaveChanges"
        case adjustYourIncome = "Income.AdjustYourIncome"
        case reset = "Income.Reset"
    }

    enum AcknowledgementsPage: String {
        case page = "Acknowledgements"
    }

    enum DashboardPage: String {
        case page = "Dashboard"
        case home = "Dashboard.Home"
        case goals = "Dashboard.Goals"
        case affordability = "Dashboard.Affordability"
    }

    enum PropertyPage: String {
        case page = "Property"
    }

    enum StateLoaderPage: String {
        case page = "StateLoader"
    }

    enum PropertyAutocompletePage: String {
        case page = "PropertyAutocomplete"
    }

    enum PropertySearchResultsPage: String {
        case page = "PropertySearchResults"
        case propertyCell = "PropertySearchResults.PropertyCell"
        case filter = "PropertySearchResults.Filter"
        case details = "PropertySearchResults.PropertyCell.PropertyDetails"
    }

    enum DashboardPropertyGoalPage: String {
        case page = "DashboardPropertyGoal"
        case delete = "DashboardPropertyGoal.Delete"
    }

    enum PropertyDetailsPage: String {
        case page = "PropertyDetails"
    }

    enum PropertyGoalPage: String {
        case page = "PropertyGoal"

        case cell = "PropertyGoal.PropertyGoalCell"
        case next = "PropertyGoal.Next"
        case minimumBedrooms = "PropertyGoal.MinimumBedrooms"
        case propertyType = "PropertyGoal.PropertyType"
        case affordability = "PropertyGoal.Affordability"
    }

    enum PropertyGoalSavingsPage: String {
        case page = "PropertyGoal.Savings"
        case proportion = "PropertyGoal.Savings.Proportion"
        case depositSavings = "PropertyGoal.Savings.DepositSavings"
        case remainingSurplus = "PropertyGoal.Savings.RemainingSurplus"
        case loanToValue = "PropertyGoal.Savings.LoanToValue"
        case next = "PropertyGoal.Savings.Next"
        case save = "PropertyGoal.Savings.Save"
    }

    enum RepaymentGoalSavingsPage: String {
        case page = "RepaymentGoal.Savings"
    }

    enum SavingsGoalPage: String {
        case page = "SavingsGoal"
        case save = "SavingsGoal.Save"
        case cancel = "SavingsGoal.Detail.Cancel"
        case amount = "SavingsGoal.Detail.Amount"
        case setAmount = "SavingsGoal.Detail.SetAmount"
        case stepper = "SavingsGoal.Detail.Stepper"
    }

    enum PropertyGoalCompletePage: String {
        case page = "PropertyGoal.Complete"
        case reviewPlan = "PropertyGoal.Complete.ReviewPlan"
        case spendingTargets = "PropertyGoal.Complete.SpendingTargets"
        case skip = "PropertyGoal.Complete.Skip"
    }

    enum PropertyGoalReviewPage: String {
        case page = "PropertyGoal.Review"
        case done = "PropertyGoal.Review.Done"
    }

    enum PropertyFilterPage: String {
        case page = "PropertyFilter"
        case search = "PropertyFilter.Search"
        case cancel = "PropertyFilter.Cancel"
        case affordability = "PropertyFilter.Affordability"
        case minimumPrice = "PropertyFilter.MinimumPrice"
        case maximumPrice = "PropertyFilter.MaximumPrice"
        case propertyType = "PropertyFilter.PropertyType"
        case radius = "PropertyFilter.Radius"
        case minimumBedrooms = "PropertyFilter.MinimumBedrooms"
    }

    enum LoginPage: String {
        case page = "Login"
        case signIn = "Login.SignIn"
        case createAccount = "Login.CreateAccount"
    }

    enum RegistrationPage: String {
        case page = "Registration"
        case givenName = "Registration.GivenName"
        case familyName = "Registration.FamilyName"
        case mobileNumber = "Registration.MobileNumber"
        case dateOfBirth = "Registration.DateOfBirth"
        case emailAddress = "Registration.EmailAddress"
        case password = "Registration.Password"
        case confirmPassword = "Registration.ConfirmPassword"
        case createAccount = "Registration.CreateAccount"
    }

    enum AccountsOnboardingPage: String {
        case page = "AccountsOnboarding"
    }

    enum AccountsPage: String {
        case page = "Accounts"
        case addMoreAccounts = "Accounts.AddMoreAccounts"
    }

    enum LinkAcountsPage: String {
        case page = "LinkAccounts"
        case save = "LinkAccounts.Save"
    }

    enum SelectProviderPage: String {
        case page = "SelectProvider"
    }

    enum PersonalDetailsPage: String {
        case page = "PersonalDetails"
        case numberOfApplicants = "PersonalDetails.NumberOfApplicants"
        case numberOfDependents = "PersonalDetails.NumberOfDependents"
        case submit = "PersonalDetails.Submit"

        case givenName = "PersonalDetails.Applicant.GivenName"
        case familyName = "PersonalDetails.Applicant.FamilyName"
        case dateOfBirth = "PersonalDetails.Applicant.DateOfBirth"
        case employmentStatus = "PersonalDetails.Applicant.EmploymentStatus"
        case occupation = "PersonalDetails.Applicant.Occupation"

        case age = "PersonalDetails.Dependent.Age"
    }

    enum DebtDisclosurePage: String {
        case page = "DebtDisclosure"
        case totalDebts = "DebtDisclosure.TotalDebts"
        case submit = "DebtDisclosure.Submit"

        case anyDebtDefaults = "DebtDisclosure.Applicant.AnyDebtDefaults"
        case howLongAgo = "DebtDisclosure.Applicant.HowLongAgo"
        case debtDefaultNotes = "DebtDisclosure.Applicant.DebtDefaultNotes"
        case anyCourtJudgements = "DebtDisclosure.Applicant.AnyCourtJudgements"
        case courtJudgementNotes = "DebtDisclosure.Applicant.CourtJudgementNotes"
    }
}
