//
//  PropertyCellViewModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 07/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import UIKit

protocol PropertyCellView: AnyObject {
    func set(headline: String?)
    func set(body: NSAttributedString?)
    func set(image: URL?)
    func set(isAffordable: Bool)
    func set(affordabilityProgress: Float)
    func set(affordabilityDescription: NSAttributedString?)
}

struct PropertyCellViewModel {
    weak var view: PropertyCellView?
    var listing: Listing
    var mortgageLimits: MortgageLimits?
    var styles: AppStyles

    init(view: PropertyCellView, listing: Listing, mortgageLimits: MortgageLimits?, styles: AppStyles) {
        self.view = view
        self.listing = listing
        self.mortgageLimits = mortgageLimits
        self.styles = styles

        view.set(headline: listing.displayableAddress)
        view.set(image: URL(string: listing.imageUrl))
        view.set(body: describeProperty(listing: listing, styles: styles))
        view.set(isAffordable: listing.internalEstimatedMonthsUntilAffordable <= 0)
        view.set(affordabilityDescription: affordabilityDescription(listing: listing, styles: styles))
        // TODO: Complete this calculation based on the required deposit etc. rather than this arbitrary calculation
        let timescale = PropertyListingsResponse.maximumAffordabilityMonths
        view.set(affordabilityProgress: (timescale - min(Float(listing.internalEstimatedMonthsUntilAffordable), timescale)) / timescale)
    }
}

public func describeAffordability(months: Int) -> String {
    let maximumYearsToDescribe = 3

    switch months {
    case 0:
        return NSLocalizedString("NOW - Affordable Now", bundle: uiBundle, comment: "NOW - Affordable Now")

    case 1 ... (maximumYearsToDescribe * 12):
        let monthsKey = NSLocalizedString("MonthsUntilKey", bundle: uiBundle, comment: "MonthsUntilKey")
        let monthDescription = String.localizedStringWithFormat(monthsKey, months)
        return String.localizedStringWithFormat("%@ Affordable", monthDescription)

    default:
        let notAffordableFormat = NSLocalizedString("Unaffordable within %u years", bundle: uiBundle, comment: "Not affordable within %u years")
        return String.localizedStringWithFormat(notAffordableFormat, maximumYearsToDescribe)
    }
}

private func affordabilityDescription(listing: Listing, styles: AppStyles) -> NSAttributedString? {
    let affordabilityStyling = AffordabilityStyling(styles: styles)

    return affordabilityDescription(monthsUntilAffordable: listing.internalEstimatedMonthsUntilAffordable, styles: affordabilityStyling)
}

private func describeProperty(listing: Listing, styles: AppStyles) -> NSAttributedString? {
    let priceAttributes: [NSAttributedString.Key: Any] = [.font: styles.fonts.sansSerif.title3,
                                                          .foregroundColor: styles.colors.text.fieldDark.color]

    let emphasisAttributes: [NSAttributedString.Key: Any] = [.font: styles.fonts.sansSerif.subheadline.bold,
                                                             .foregroundColor: styles.colors.text.fieldDark.color]
    let defaultAttributes: [NSAttributedString.Key: Any] = [.font: styles.fonts.sansSerif.subheadline,
                                                            .foregroundColor: styles.colors.text.fieldDark.color]

    let propertyDetails = NSMutableAttributedString()

    let price = MonetaryAmount(amount: listing.priceValue).shortDescription

    propertyDetails.append(price, attributes: priceAttributes)
    propertyDetails.append(String.paragraphBreak, attributes: priceAttributes)

    let numberOfBedrooms = String.localizedStringWithFormat(NSLocalizedString("NumberOfBedroomsKey", bundle: uiBundle, comment: "NumberOfBedroomsKey"),
                                                            listing.numberOfBedrooms)
    let propertyDescriptionFormat = NSLocalizedString("%1$@ - %2$@", comment: "Property Description Format: bedrooms, type")
    let propertyType = listing.propertyType.isEmpty ?
        NSLocalizedString("Other", bundle: uiBundle, comment: "PropertyType - Other")
        : listing.propertyType.localizedCapitalized
    let propertyDescription = String.localizedStringWithFormat(propertyDescriptionFormat, numberOfBedrooms, propertyType)

    let formattedDescription = NSMutableAttributedString(string: propertyDescription, attributes: defaultAttributes)
    formattedDescription.set(attributes: emphasisAttributes, firstRangeOf: numberOfBedrooms)
    propertyDetails.append(formattedDescription)

    let affordability = describeAffordability(months: listing.internalEstimatedMonthsUntilAffordable)

    propertyDetails.append(String.paragraphBreak, attributes: defaultAttributes)
    propertyDetails.append(affordability, attributes: defaultAttributes)

    return propertyDetails
}
