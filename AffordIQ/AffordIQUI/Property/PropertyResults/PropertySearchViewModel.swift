//
//  PropertySearchViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Combine
import Foundation
import AffordIQFoundation
import AffordIQAuth0
import AffordIQNetworkKit

struct PropertySearchFilter: Equatable {
    var maximumPrice: Decimal?
    var minimumBedrooms: Int?
    var propertyType: String?
    var months: Int?

    var isEmpty: Bool {
        return numberOfFilters == 0
    }
    
    var numberOfFilters: Int {
        let filters: [Any?] = [maximumPrice, propertyType, minimumBedrooms, months]
        return filters.compactMap { $0 }.count
    }
}

let propertyFilterPriceIncrement: Decimal = 25000.00

func rounded(maximumPrice price: Decimal?) -> Decimal? {
    guard let price = price else { return nil }
    return (price / propertyFilterPriceIncrement).rounded(places: 0, roundingMode: .up) * propertyFilterPriceIncrement
}

let propertyTypeFilters: [String: Set<String>] = [
    "houses": ["Terraced house", "End of terrace house", "Semi-detached house", "Detached house", "Mews house", "Bungalow", "Town house", "Cottage"],
    "flats": ["Flat", "Maisonette"]
]

func propertyTypeFilter(from propertyType: String?) -> String? {
    guard let propertyType = propertyType else { return nil }
    return propertyTypeFilters.first { $1.contains(propertyType) }?.key
}

extension Listing {
    private func satisfiesPriceCriteria(filter: PropertySearchFilter) -> Bool {
        if let price = priceValue {
            if let maximumPrice = filter.maximumPrice,
               price > maximumPrice {
                return false
            }
        }

        return true
    }

    private func satisfiesTypeCriteria(filter: PropertySearchFilter) -> Bool {
        if !propertyType.isEmpty,
           let propertyType = filter.propertyType,
           let propertyTypes = propertyTypeFilters[propertyType],
           !propertyTypes.contains(self.propertyType) {
            return false
        }

        return true
    }

    private func satisfiesBedroomCriteria(filter: PropertySearchFilter) -> Bool {
        if let minimumBedrooms = filter.minimumBedrooms,
           numberOfBedrooms < minimumBedrooms {
            return false
        }

        return true
    }
    
    private func satisfiesMonthsCriteria(filter: PropertySearchFilter) -> Bool {
        if let months = filter.months,
           internalEstimatedMonthsUntilAffordable > months {
            return false
        }
        
        return true
    }

    func satisfies(filter: PropertySearchFilter) -> Bool {
        return satisfiesPriceCriteria(filter: filter)
        && satisfiesTypeCriteria(filter: filter)
        && satisfiesBedroomCriteria(filter: filter)
    }
}

public extension RangeReplaceableCollection {
    @inlinable init(generating generatedValue: @autoclosure () -> Element, count: Int) {
        self = .init()
        reserveCapacity(count)
        for _ in 0 ..< count {
            append(generatedValue())
        }
    }
}

enum PropertySearchResult: Equatable, Hashable {
    case placeholder(pageNumber: Int)
    case noResults
    case result(listing: Listing)

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .placeholder(pageNumber):
            hasher.combine("PLACEHOLDER")
            hasher.combine(pageNumber)
        case .noResults:
            hasher.combine("NORESULTS")
        case let .result(listing):
            hasher.combine(listing.listingId)
        }
    }
}

protocol PropertySearchViewModelType {
    var searchFilter: PropertySearchFilter { get set }
    var search: Suggestion { get }
    var searchResults: AnyPublisher<[PropertySearchResult], Error> { get }
    var filterCount: AnyPublisher<Int, Error> { get }
    
    func willApply(filter: PropertySearchFilter)
    func nextPage()
}

public struct HostDependencies: DefaultDependenciesType {
    public let session: SessionType
    public let styles: AppStyles
    
    public init(session: SessionType, styles: AppStyles) {
        self.session = session
        self.styles = styles
    }
}

class PropertySearchViewModel: PropertySearchViewModelType {
    let pageSize = 200
    let search: Suggestion
    
    var results: [PropertySearchResult] = []
    var filteredResults: [PropertySearchResult] = []
    var availableResults: Int?
    var mortgageLimits: MortgageLimits?
    var subscriptions: Set<AnyCancellable> = []
    var searchFilter: PropertySearchFilter = .init()
    var searchParameters: ChosenPropertyParameters
    let goalSource: GoalSource
    var propertyQuantity: Int = 0
    
    @Published var zooplaErrorAlert: Bool = false
    @Published var showNext: Bool?
    @Published var error: Error?
    @Published var isLoading: Bool = false
    var pages: [Int: PageStatus] = [:]
    var pageNumber: Int = 1 {
        didSet {
            PropertyManager.shared.pageNumber = pageNumber
        }
    }
    
    private var propertySource: PropertySource
    var userSession: SessionType
    var months: Int
    
    private var resultsPublisher: CurrentValueSubject<[PropertySearchResult], Error>
    private var filterCountPublisher: CurrentValueSubject<Int, Error>

    lazy var searchResults: AnyPublisher<[PropertySearchResult], Error> = resultsPublisher.eraseToAnyPublisher()
    lazy var filterCount: AnyPublisher<Int, Error> = filterCountPublisher.removeDuplicates().eraseToAnyPublisher()

    init(search: Suggestion,
         parameters: ChosenPropertyParameters,
         mortgageLimits: MortgageLimits?,
         propertySource: PropertySource = PropertyService(),
         userSession: SessionType = Auth0Session.shared,
         goalSource: GoalSource = GoalService(),
         months: Int
    ) {
        self.mortgageLimits = mortgageLimits
        self.searchParameters = parameters
        self.search = search
        self.propertySource = propertySource
        self.userSession = userSession
        self.goalSource = goalSource
        self.months = months
        self.pageNumber = PropertyManager.shared.pageNumber
        
        if months != 36 {
            searchFilter.months = months
        } else {
            searchFilter.months = 100
        }
        
        resultsPublisher = CurrentValueSubject<[PropertySearchResult], Error>([])
        filterCountPublisher = CurrentValueSubject<Int, Error>(searchFilter.numberOfFilters)
        
        getProperties()
    }

    func getProperties() {
        guard let userID = userSession.userID else { return }
        
        let data = RMGetPropertyList(
            bedrooms: searchParameters.bedrooms == nil ? nil : Int(searchParameters.bedrooms!),
            price: searchParameters.homeValue,
            pageNumber: pageNumber,
            pageSize: pageSize,
            area: searchParameters.suggestion.value,
            propertyType: searchParameters.propertyType?.uppercased(),
            userId: userID
        )
        
        PropertyManager.shared.propertySearchParameters = data
        if let listings = PropertyManager.shared.propertyListings {
            process(listingsResponse: PropertyManager.shared.propertyListings)
            availableResults = listings.resultCount
        } else {
            Task {
                isLoading = true
                await fetchProperties(request: data)
                isLoading = false
            }
        }
    }
    
    @MainActor
    func fetchProperties(request: RMGetPropertyList) async {
        pages[request.pageNumber] = .loading
        
        do {
            let properties = try await propertySource.getListings(model: request)
            let propertyListings = PropertyListings(
                pageNumber: pageNumber,
                pageSize: request.pageSize,
                response: properties
            )

            pageNumber += 1
            propertyQuantity = properties.resultCount
            PropertyManager.shared.propertyListings = propertyListings.response
            
            getAvailableResults(listings: propertyListings)
            process(listingsResponse: propertyListings.response)
            
            pages[request.pageNumber] = .loaded
        } catch {
            if error._code == 429 {
                zooplaErrorAlert = true
            }
            if error.localizedDescription.contains("429") {
                zooplaErrorAlert = true
            }
            self.error = error
            pages[request.pageNumber] = .unknown
        }
    }
    
    func filterPlaceholders(_ value: PropertySearchResult) -> Bool {
        switch value {
        case .placeholder:
            return false
        case .noResults:
            return false
        default:
            return true
        }
    }
    
    func nextPage() {
        let noPlaceholderCount = results.filter { filterPlaceholders($0) }.count
        guard let userID = userSession.userID, let availableResults = availableResults, noPlaceholderCount < availableResults else {
            return }
        
        let page = ((noPlaceholderCount + 1) / pageSize) + 1
        let data = RMGetPropertyList(
            bedrooms: searchParameters.bedrooms == nil ? nil : Int(searchParameters.bedrooms!),
            price: searchParameters.homeValue,
            pageNumber: page,
            pageSize: pageSize,
            area: searchParameters.suggestion.value,
            propertyType: searchParameters.propertyType?.uppercased(),
            userId: userID
        )
        Task {
            await fetchProperties(request: data)
        }
    }
    
    private func filter(listing: PropertySearchResult) -> Bool {
        switch listing {
        case .placeholder:
            return true
        case .noResults:
            return false
        case let .result(listing):
            return ListingStatus.saleStatusValues.contains(listing.status)
            && listing.satisfies(filter: searchFilter)
        }
    }
    
    func isAffordable(listing: Listing) -> Bool {
        return listing.internalEstimatedMonthsUntilAffordable < 1
    }
    
    private func presentResults() {
        filteredResults = results.filter(filter(listing:))
        if let uniqueResults: [PropertySearchResult] = NSOrderedSet(array: filteredResults).array as? [PropertySearchResult] {
            if uniqueResults.isEmpty {
                resultsPublisher.send([.noResults])
            } else {
                resultsPublisher.send(uniqueResults)
            }
        }
    }
    
    private func getAvailableResults(listings: PropertyListings?) {
        if let resultCount = listings?.response?.resultCount {
            availableResults = resultCount
        }
    }
    
    private func process(listingsResponse: PropertyListingsResponse?) {
        if let response = listingsResponse {
            results = results.filter { filterPlaceholders($0) }
            let values = response.listing.map { PropertySearchResult.result(listing: $0) }
            
            results.append(contentsOf: values)
            
            if results.count < response.resultCount {
                results.append(PropertySearchResult.placeholder(pageNumber: pageNumber))
            }
            
            presentResults()
        } else {
            resultsPublisher.send([.placeholder(pageNumber: 1)])
        }
    }
    
    func willApply(filter: PropertySearchFilter) {
        searchFilter = filter
        let numberOfFilters = filter.numberOfFilters
        filterCountPublisher.send(numberOfFilters)
        
        presentResults()
    }
    
    @MainActor
    func setPropertyGoal(listing: Listing) async {
        do {
            guard let userID = userSession.userID, let request = RMPropertyGoal(listing: listing) else { throw NetworkError.unauthorized }
            
            try await goalSource.setPropertyGoal(userID: userID, model: request)
            showNext = true
        } catch {
            self.error = error
        }
    }
}
