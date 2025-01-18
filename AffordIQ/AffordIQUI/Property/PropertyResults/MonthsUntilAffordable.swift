//
//  MonthsUntilAffordable.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 24/03/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import Foundation
import UIKit

struct AffordabilityStyling {
    let now: UIFont
    let month: UIFont
    let legend: UIFont
    let foregroundColor: UIColor
    let paragraphStyle: NSParagraphStyle
    
    init(now: UIFont, month: UIFont, legend: UIFont, foregroundColor: UIColor, paragraphStyle: NSParagraphStyle?) {
        self.now = now
        self.month = month
        self.legend = legend
        self.foregroundColor = foregroundColor
        
        if let paragraphStyle = paragraphStyle {
            self.paragraphStyle = paragraphStyle
        } else {
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            self.paragraphStyle = paragraph
        }
    }
    
    init(styles: AppStyles) {
        self.init(now: styles.fonts.sansSerif.title2.black,
                  month: styles.fonts.sansSerif.title3.black,
                  legend: styles.fonts.sansSerif.caption2,
                  foregroundColor: styles.colors.text.fieldDark.color,
                  paragraphStyle: nil)
    }
}

func affordabilityDescription(monthsUntilAffordable: Int, styles: AffordabilityStyling) -> NSAttributedString? {
    let nowAttributes: [NSAttributedString.Key: Any] = [.font: styles.now,
                                                        .foregroundColor: styles.foregroundColor,
                                                        .paragraphStyle: styles.paragraphStyle]
    let monthAttributes: [NSAttributedString.Key: Any] = [.font: styles.month,
                                                          .foregroundColor: styles.foregroundColor,
                                                          .paragraphStyle: styles.paragraphStyle]
    let legendAttributes: [NSAttributedString.Key: Any] = [.font: styles.legend,
                                                           .foregroundColor: styles.foregroundColor,
                                                           .paragraphStyle: styles.paragraphStyle]
    
    let timescale = PropertyListingsResponse.maximumAffordabilityMonthsInt
    let result = NSMutableAttributedString()
    
    switch monthsUntilAffordable {
    case Int.min ..< 0:
        result.append("36+", attributes: monthAttributes)
        result.append(.paragraphBreak, attributes: legendAttributes)
        result.append(NSLocalizedString("MONTHS", bundle: uiBundle, comment: "MONTHS"), attributes: legendAttributes)
        
    case 0:
        result.append(NSLocalizedString("NOW", bundle: uiBundle, comment: "NOW"), attributes: nowAttributes)
        
    case 1:
        result.append("\(monthsUntilAffordable)", attributes: monthAttributes)
        result.append(.paragraphBreak, attributes: legendAttributes)
        result.append(NSLocalizedString("MONTH", bundle: uiBundle, comment: "MONTH"), attributes: legendAttributes)
        
    case 2 ... 35:
        result.append("\(monthsUntilAffordable)", attributes: monthAttributes)
        result.append(.paragraphBreak, attributes: legendAttributes)
        result.append(NSLocalizedString("MONTHS", bundle: uiBundle, comment: "MONTHS"), attributes: legendAttributes)
        
    case 36 ... timescale:
        result.append("36+", attributes: monthAttributes)
        result.append(.paragraphBreak, attributes: legendAttributes)
        result.append(NSLocalizedString("MONTHS", bundle: uiBundle, comment: "MONTHS"), attributes: legendAttributes)
        
    default:
        
        result.append(NSLocalizedString("OVER", bundle: uiBundle, comment: "OVER"), attributes: legendAttributes)
        result.append(.paragraphBreak, attributes: legendAttributes)
        result.append("\(timescale)", attributes: monthAttributes)
        result.append(.paragraphBreak, attributes: legendAttributes)
        result.append(NSLocalizedString("MONTHS", bundle: uiBundle, comment: "MONTHS"), attributes: legendAttributes)
    }
    
    return result
}
