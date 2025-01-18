//
//  PropertyCellBoundView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 11/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

protocol PropertyCellBoundView: PropertyCellView, Stylable {
    var viewModel: PropertyCellViewModel? { get set }

    var headline: UILabel? { get }
    var body: UILabel? { get }
    var thumbnail: UIImageView? { get }
    var affordabilityProgress: CircularMeterView? { get }
    var affordabilityDescription: UILabel? { get }
    var bubbleBackground: UIView? { get }

    func bind(mortgageLimits: MortgageLimits?, result: PropertySearchResult)
}

extension PropertyCellBoundView {
    func bind(mortgageLimits: MortgageLimits?, result: PropertySearchResult) {
        apply(styles: AppStyles.shared)

        if case let PropertySearchResult.result(listing) = result {
            viewModel = PropertyCellViewModel(view: self, listing: listing, mortgageLimits: mortgageLimits, styles: AppStyles.shared)
        }
    }

    func set(affordabilityProgress: Float) {
        self.affordabilityProgress?.progress = affordabilityProgress
    }

    func set(headline: String?) {
        self.headline?.text = headline
    }

    func set(body: NSAttributedString?) {
        self.body?.attributedText = body
    }

    func set(image: URL?) {
        thumbnail?.sd_setImage(with: image)
    }

    func set(isAffordable _: Bool) {
        // Unused
    }

    func set(affordabilityDescription: NSAttributedString?) {
        self.affordabilityDescription?.attributedText = affordabilityDescription
    }
}
