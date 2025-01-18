//
//  PropertyParametersViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11.03.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Combine
import AffordIQNetworkKit
import AffordIQAuth0

struct PropertyParameters {
    var title: String
    var value: String = "any"
    var options: [String]
}

public struct ChosenPropertyParameters {
    var suggestion: Suggestion
    var homeValue: Decimal
    var bedrooms: String?
    var propertyType: String?
}

class PropertyParametersViewModel {
    var suggestions: [Suggestion] = []
    var searchText: String = ""
    var isFilter = true
    var parameters: [PropertyParameters] = [PropertyParameters(title: "Minimum Bedrooms", options: ["any", "1", "2", "3", "4", "5", "6", "7"]), PropertyParameters(title: "Property Type", options: ["any", "Flat", "Houses"])]
    let autocompleteMinimumLength = 2
    let autocompleteMaximumLength = 15
    var parameterIndex = 0
    var selectedSuggestion: Suggestion?
    var subscriptions: Set<AnyCancellable> = []
    var mortgageLimits: MortgageLimits?
    var homeValue: Decimal
    var isDashboard: Bool
    var months: Int
    
    private let affordabilitySource: AffordabilitySource
    private let propertySource: PropertySource
    let session: SessionType
    
    @Published var updateData: Bool = false
    @Published var updateButton: Bool = false
    @Published var chosenPropertyParameters: ChosenPropertyParameters?
    @Published var error: Error?
    
    init(homeValue: Decimal, 
         parameters: ChosenPropertyParameters?,
         months: Int,
         isDashboard: Bool,
         session: SessionType = Auth0Session.shared,
         propertySource: PropertySource = PropertyService(),
         affordabilitySource: AffordabilitySource = AffordabilityService()) {
        self.homeValue = homeValue
        self.isDashboard = isDashboard
        self.months = months
        self.session = session
        self.propertySource = propertySource
        self.affordabilitySource = affordabilitySource
        
        if let search = parameters {
            selectedSuggestion = search.suggestion
            self.parameters[0].value = search.bedrooms ?? "any"
            self.parameters[1].value = search.propertyType ?? "any"
        }

        Task {
            await getMonthsUntilAffordable()
        }

        self.updateData = true
    }
    
    @MainActor
    func getMonthsUntilAffordable() async {
        guard let userID = session.userID else { return }

        do {
            let response = try await affordabilitySource.getGoalTrackingAndMortgageLimits(userID: userID)
            mortgageLimits = response.mortgageLimits
        } catch {
            self.error = error
        }
    }
    
    @MainActor
    func autocomplete(_ text: String) async {
        searchText = text
        suggestions = []

        if let suggestion = selectedSuggestion {
            let separators = CharacterSet(charactersIn: "[]")
            let value = suggestion.value.components(separatedBy: separators).compactMap { $0.sanitized }.joined(separator: " ")
            if text != value {
                selectedSuggestion = nil
                updateButton = true
            }
        }

        let searchTerm = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if searchTerm.count > autocompleteMaximumLength || searchTerm.count < autocompleteMinimumLength {
            isFilter = true
            updateData = true
            return
        }

        do {
            let response = try await propertySource.getAutocomplete(searchTerm: searchTerm)
            suggestions = response.suggestions
            isFilter = false
            updateData = true
        } catch {
            self.error = error
        }
    }

    func prepareResults() {
        if let search = selectedSuggestion {
            let bedrooms = parameters.first?.value == "any" ? nil : parameters.first?.value
            chosenPropertyParameters = ChosenPropertyParameters(suggestion: search, homeValue: homeValue, bedrooms: bedrooms, propertyType: parameters.last?.value)
        }
    }
}
