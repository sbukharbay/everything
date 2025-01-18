//
//  AffordabilityMainViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 14.02.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import AffordIQNetworkKit
import AffordIQAuth0
import Combine

class AffordabilityMainViewModel {
    @Published var error: Error?
    @Published var zeroAffordabilityAlert: Bool?
    @Published var calculation: MonthlyCalculations?
    @Published var filters: (ChosenPropertyParameters?, MortgageLimits?)?
    @Published var isDone = false
    var monthSubject = PassthroughSubject<Int, Never>()
    var updateData = PassthroughSubject<Int, Never>()
    
    var affordabilityCalculations: [AffordabilityCalculations]
    var overlayData: AffordabilityData?
    var mortgageDetails: MortgageDetails?
    var viewType: AffordabilityMainViewType
    var months: [Int]
    var monthlyPercentages: [Int: [Int]]
    var isDashboard: Bool
    var getStartedType: GetStartedViewType
    var currentDeposit: Int?
    var currentMonthRow: Int?
    var chosenMonth: Int = 100
    var affordabilitySource: AffordabilitySource
    var userSession: SessionType
    
    var firstValidMonthlyPeriod: Int {
        return affordabilityCalculations.first(where: { $0.selected })?
            .homeCalculations.first(where: { $0.valid })?
            .monthlyPeriod ?? 0
    }

    init(type: AffordabilityMainViewType,
         getStartedType: GetStartedViewType?,
         affordabilitySource: AffordabilitySource = AffordabilityService(),
         userSession: SessionType = Auth0Session.shared,
         isDashboard: Bool) {
        self.affordabilitySource = affordabilitySource
        self.userSession = userSession
        self.viewType = type
        self.isDashboard = isDashboard
        
        affordabilityCalculations = []
        months = [0, 3, 6, 9, 12, 18, 24, 36]
        monthlyPercentages = [:]
        
        if let type = getStartedType {
            self.getStartedType = type
        } else {
            self.getStartedType = .goal
        }

        resume()
    }

    @MainActor
    func getAffordabilityCalculations() async {
        do {
            guard let userID = userSession.userID else { throw NetworkError.unauthorized }
            let response = try await affordabilitySource.getAffordabilityCalculations(userID: userID, model: nil)
            
            guard let calculations = response.affordabilityCalculations else { throw NetworkError.emptyObject }
            affordabilityCalculations = calculations
            if !affordabilityCalculations.contains(where: { $0.containsValidResults }) {
                zeroAffordabilityAlert = true
            } else {
                selectedAffordabilityCalculation()
                getMonths()
            }
            BusyView.shared.hide(success: true)
        } catch {
            self.error = error
            BusyView.shared.hide(success: false)
        }
    }

    private func selectedAffordabilityCalculation() {
        affordabilityCalculations.sort { $0.depositPercentage < $1.depositPercentage }
        affordabilityCalculations.removeAll(where: { !$0.containsValidResults })
        monthlyPercentages = [:]
        
        affordabilityCalculations.forEach { calculations in
            calculations.homeCalculations.forEach({ monthly in
                if monthly.valid {
                    if monthlyPercentages[monthly.monthlyPeriod] == nil {
                        monthlyPercentages[monthly.monthlyPeriod] = [calculations.depositPercentage]
                    } else {
                        monthlyPercentages[monthly.monthlyPeriod]?.append(calculations.depositPercentage)
                    }
                }
            })
        }
        
        if let percentage = currentDeposit, let index = affordabilityCalculations.firstIndex(where: { $0.depositPercentage == percentage }) {
            affordabilityCalculations[index].selected = true
            selectMonth(index)
        } else if let index = affordabilityCalculations.firstIndex(where: { $0.depositPercentage == 10 && $0.containsValidResults }) {
            select(index)
        } else if let index = affordabilityCalculations.firstIndex(where: { $0.containsValidResults }) {
            select(index)
        }
    }

    private func select(_ index: Int) {
        affordabilityCalculations[index].selected = true

        switch viewType {
        case let .filter(search, _):
            let selected = affordabilityCalculations.first { $0.selected }
            guard let previousSelection = selected?.homeCalculations.firstIndex(where: { $0.homeValue.amount == search.homeValue }) else { return selectMonth(index) }
            select(index: previousSelection)
        default:
            selectMonth(index)
        }
    }

    private func selectMonth(_ index: Int) {
        if let row = currentMonthRow {
            select(index: row)
        }

        if !affordabilityCalculations[index].homeCalculations.contains(where: { $0.isSelected }), let i = affordabilityCalculations[index].homeCalculations.firstIndex(where: { item in
            item.valid && item.monthlyPeriod >= months[months.count / 2]
        }) {
            select(index: i)
        }

        if !affordabilityCalculations[index].homeCalculations.contains(where: { $0.isSelected }), let i = affordabilityCalculations[index].homeCalculations.firstIndex(where: { item in
            item.valid && item.monthlyPeriod < months[months.count / 2]
        }) {
            select(index: i)
        }
    }

    private func select(index: Int) {
        currentMonthRow = index

        affordabilityCalculations.enumerated().forEach { j, _ in
            if affordabilityCalculations[j].homeCalculations.indices.contains(index) {
                affordabilityCalculations[j].homeCalculations[index].isSelected = true
            }
        }
    }

    func showPropertySearch() {
        isDone = true
        let selected = affordabilityCalculations.first { $0.selected }
        calculation = selected?.homeCalculations.first { $0.isSelected }
        isDone = false
    }

    func showResults() {
        switch viewType {
        case let .filter(search, mortgageLimits):
            let selected = affordabilityCalculations.first { $0.selected }
            let calculation = selected?.homeCalculations.first { $0.isSelected }
            var newSearch = search
            newSearch.homeValue = calculation?.homeValue.amount ?? 0

            filters = (newSearch, mortgageLimits)
        default:
            break
        }
    }

    func getMonths() {
        var monthsCount = months[currentMonthRow ?? 0]
        
        for data in affordabilityCalculations where data.selected {
            for item in data.homeCalculations where item.isSelected {
                monthsCount = item.monthlyPeriod
            }
        }
        
        chosenMonth = monthsCount
        monthSubject.send(monthsCount)
        
        // update percentage
        if let monthly = monthlyPercentages[chosenMonth], let percentage = currentDeposit, let row = monthly.firstIndex(of: percentage) {
            selectPercentage(row)
        } else {
            selectPercentage(0)
        }
    }

    func selectPercentage(_ row: Int) {
        if let percentage = monthlyPercentages[chosenMonth]?[row],
           let index = affordabilityCalculations.firstIndex(where: { $0.depositPercentage == percentage }) {
            
            affordabilityCalculations.enumerated().forEach { i, _ in
                affordabilityCalculations[i].selected = false
            }

            affordabilityCalculations[index].selected = true
            currentDeposit = affordabilityCalculations[index].depositPercentage
            
            Task {
                await getMortgageDetails()
            }
        }
    }

    @MainActor
    func getMortgageDetails() async {
        let selected = affordabilityCalculations.first { $0.selected }
        let calculation = selected?.homeCalculations.first { $0.isSelected }

        guard let property = calculation, let userID = userSession.userID else { return }

        do {
            let description = property.homeValue.amount?.description ?? "0"
            let absoluteValue = (Double(selected?.depositPercentage ?? 0) / 100.0).description

            let response = try await affordabilitySource.getMortgageDetails(userID: userID,
                                                                            depositAbsoluteValue: absoluteValue,
                                                                            propertyValue: description)
            mortgageDetails = response.mortgageDetails
            setOverlayData()
        } catch {
            self.error = error
        }
    }

    func setOverlayData() {
        guard let data = mortgageDetails else { return }

        switch viewType {
        case .tabbar:
            overlayData = AffordabilityData(
                info: OverlayData(icon: "mortgage", title: "Expected Mortgage", value: ""),
                details: [
                    OverlayData(icon: "mortgage", title: "Mortgage", value: data.mortgage.shortDescription),
                    OverlayData(icon: "sterlingsign.circle", title: "Repayments", value: data.repayment.shortDescription + "/m"),
                    OverlayData(icon: "interest_rate", title: "Interest Rate", value: String(format: "%.1f", data.interestRate * 100) + "%"),
                    OverlayData(icon: "clock.arrow.circlepath", title: "Mortgage Term", value: data.term.description)
                ]
            )
        default:
            overlayData = AffordabilityData(
                info: OverlayData(icon: "mortgage", title: "Mortgage Repayments", value: data.repayment.shortDescription + "/m"),
                details: [
                    OverlayData(icon: "sterlingsign.circle", title: "Repayments", value: data.repayment.shortDescription + "/m"),
                    OverlayData(icon: "mortgage", title: "Mortgage", value: data.mortgage.shortDescription),
                    OverlayData(icon: "interest_rate", title: "Interest Rate", value: String(format: "%.1f", data.interestRate * 100) + "%"),
                    OverlayData(icon: "clock.arrow.circlepath", title: "Mortgage Term", value: data.term.description)
                ]
            )
        }

        guard let month = monthlyPercentages[chosenMonth], let currentDeposit, let index = month.firstIndex(of: currentDeposit) else { return }
        updateData.send(index)
    }

    func resume() {
        Task {
            await getAffordabilityCalculations()
        }
    }
}
