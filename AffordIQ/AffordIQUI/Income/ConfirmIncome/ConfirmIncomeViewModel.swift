//
//  ConfirmIncomeViewModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 16/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Amplitude
import Combine
import UIKit
import AffordIQNetworkKit
import AffordIQAuth0

class ConfirmIncomeViewModel {
    @Published var error: Error?
    @Published var isLoading: Bool = false
    @Published var isDone: Bool = false
    let willUpdateSubject = PassthroughSubject<Bool, Never>()
    let didOperationCompleteSubject = PassthroughSubject<Bool, Never>()
    
    var incomeData: IncomeStatusDataModel?
    var rowTitle: [ConfirmIncomeModel] = []
    var monthlyTakeHome = ""
    var annualBaseSalary = ""
    var annualBonusPay = ""
    var getStartedType: GetStartedViewType = .income
    var isSettings: Bool = false
    
    let affordabilitySource: AffordabilitySource
    let userSource: UserSource
    let userSession: SessionType

    init(incomeData: IncomeStatusDataModel?,
         getStartedType: GetStartedViewType?,
         isBack: Bool,
         isSettings: Bool,
         affordabilitySource: AffordabilitySource = AffordabilityService(),
         userSource: UserSource = UserService(),
         userSession: SessionType = Auth0Session.shared) {
        self.incomeData = incomeData
        self.isSettings = isSettings
        self.affordabilitySource = affordabilitySource
        self.userSource = userSource
        self.userSession = userSession

        if let type = getStartedType {
            self.getStartedType = type
        }

        if isBack {
            Task {
                isLoading = true
                await getIncomeBreakdown()
                isLoading = false
            }
        } else {
            setValues()
        }
    }

    func setValues() {
        switch incomeData?.employmentStatus {
        case .selfEmployed:
            guard let period = incomeData?.selfEmploymentData?.months else { return }
            let years = period / 12
            let months = period % 12
            
            rowTitle = [
                ConfirmIncomeModel(subTitle: "Employment Status", value: incomeData?.employmentStatus.getText() ?? ""),
                ConfirmIncomeModel(subTitle: incomeData?.selfEmploymentData?.type.getText() ?? "", value: years.description + " Yr, " + months.description + " Mo")
            ]
            
            if let months = incomeData?.selfEmploymentData?.months, months < 24 {
                rowTitle.append(contentsOf: [
                    ConfirmIncomeModel(subTitle: "Annual Income Before Tax", value: incomeData?.selfEmploymentData?.profitBT?.shortDescription ?? ""),
                    ConfirmIncomeModel(subTitle: "Annual Income After Tax (Proposed)", value: incomeData?.selfEmploymentData?.profitAT?.shortDescription ?? "")
                ])
            } else {
                rowTitle.append(contentsOf: [
                    ConfirmIncomeModel(subTitle: "Annual Income Before Tax", value: incomeData?.selfEmploymentData?.incomeBT?.shortDescription ?? ""),
                    ConfirmIncomeModel(subTitle: "Annual Income After Tax (Proposed)", value: incomeData?.selfEmploymentData?.incomeAT?.shortDescription ?? "")
                ])
            }
        case .employed:
            var monthlyTakeHome: String {
                let monthlyToDouble = incomeData?.monthly.formatAndConvert() ?? 0
                let result = String(format: "%.2f", monthlyToDouble)
                return result.currencyInputFormatting()
            }

            var annualBaseSalary: String {
                let salaryToDouble = incomeData?.salary.formatAndConvert() ?? 0
                let result = String(format: "%.2f", salaryToDouble)
                return result.currencyInputFormatting()
            }

            var annualBonusPay: String {
                let bonusToDouble = incomeData?.bonus.formatAndConvert() ?? 0
                let result = String(format: "%.2f", bonusToDouble)
                return result.currencyInputFormatting()
            }

            self.annualBaseSalary = annualBaseSalary
            self.monthlyTakeHome = monthlyTakeHome
            self.annualBonusPay = annualBonusPay

            rowTitle = [
                ConfirmIncomeModel(subTitle: "Employment Status", value: incomeData?.employmentStatus.getText() ?? ""),
                ConfirmIncomeModel(subTitle: "Annual Base Salary", value: annualBaseSalary),
                ConfirmIncomeModel(subTitle: "Additional Work Payments", value: annualBonusPay),
                ConfirmIncomeModel(subTitle: "Monthly Take Home Pay", value: monthlyTakeHome)
            ]
        default:
            break
        }
        
        willUpdateSubject.send(true)
    }

    @MainActor
    func getIncomeBreakdown() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await affordabilitySource.getIncomeStatus(userID: userID)
            
            switch response.employmentStatus {
            case .selfEmployed:
                guard let type = response.selfEmploymentType,
                      let months = response.numberOfMonths,
                      let incomeAT = response.earningsAfterTax,
                      let incomeBT = response.incomeBeforeTax,
                      let profitAT = response.profitsAfterTax,
                      let profitBT = response.profitsBeforeTax else { throw NetworkError.emptyObject }
                let selfEmployedData = SelfEmploymentData(type: type, months: months, incomeBT: incomeBT, incomeAT: incomeAT, profitBT: profitBT, profitAT: profitAT)
                self.incomeData = IncomeStatusDataModel(employmentStatus: response.employmentStatus, salary: "", bonus: "", monthly: "", selfEmploymentData: selfEmployedData)
            default:
                guard let salary = response.annualGrossSalary,
                      let bonus = response.annualBonusPayments,
                      let monthly = response.monthlyNetSalary else { throw NetworkError.emptyObject }
                self.incomeData = IncomeStatusDataModel(employmentStatus: response.employmentStatus, salary: salary.description, bonus: bonus.description, monthly: monthly.description)
            }
            
            setValues()
        } catch {
            self.error = error
        }
    }

    @MainActor
    func setConfirmIncome() async {
        isDone = true
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            await setIncomeStatus(userID: userID)
            await checkCurrentState()
            didOperationCompleteSubject.send(true)
        } catch {
            self.error = error
        }
        isDone = false
    }
    
    func setIncomeStatus(userID: String) async {
        do {
            switch incomeData?.employmentStatus {
            case .selfEmployed:
                guard let data = incomeData?.selfEmploymentData else { return }
                
                let model = RMIncomeConfirmation(
                    employmentStatus: incomeData?.employmentStatus.rawValue ?? "",
                    earningsAfterTax: data.incomeAT,
                    incomeBeforeTax: data.incomeBT,
                    profitsAfterTax: data.profitAT,
                    profitsBeforeTax: data.profitBT,
                    numberOfMonths: data.months,
                    selfEmploymentType: data.type
                )
                
                try await affordabilitySource.setIncomeStatus(userID: userID, model: model)
            default:
                let model = RMIncomeConfirmation(
                    employmentStatus: incomeData?.employmentStatus.rawValue ?? "",
                    annualGrossSalary: MonetaryAmount(amount: Decimal(annualBaseSalary.formatAndConvert())),
                    annualBonusPayments: MonetaryAmount(amount: Decimal(annualBonusPay.formatAndConvert())),
                    monthlyNetSalary: MonetaryAmount(amount: Decimal(monthlyTakeHome.formatAndConvert()))
                )
                
                try await affordabilitySource.setIncomeStatus(userID: userID, model: model)
            }
        } catch {
            self.error = error
        }
    }

    @MainActor
    func checkCurrentState() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            
            let response = try await userSource.getUserStatus(userID: userID)
            
            #if DEBUG
            print("Next Step ", response.nextStep.rawValue)
            #endif
        } catch {
        }
    }
}
