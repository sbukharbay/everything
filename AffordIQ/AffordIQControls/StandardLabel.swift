//
//  StandardLabel.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 27/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@IBDesignable public class StandardLabel: UILabel {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        defaultSetup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        defaultSetup()
    }

    func defaultSetup() {
        adjustsFontForContentSizeCategory = true
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        if let stylable = self as? Stylable,
           let defaultStyles = InterfaceBuilderStyles.styles {
            stylable.apply(styles: defaultStyles)
        }
    }
}

/// 17
@IBDesignable public class FieldLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension FieldLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.headline
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 15
@IBDesignable public class FieldLabelSubheadlineLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension FieldLabelSubheadlineLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 15
@IBDesignable public class InfoLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension InfoLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline.light
        textColor = UIColor(hex: "#484E59")
    }
}

/// 15
@IBDesignable public class FieldLabelSubheadlineLightBold: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension FieldLabelSubheadlineLightBold: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline.semiBold
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 15
@IBDesignable public class ErrorLabel: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor(hex: "#F25A85")
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension ErrorLabel: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline
        textColor = styles.colors.text.error.color
    }
}

/// 15
@IBDesignable public class FieldLabelDark: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension FieldLabelDark: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 13
@IBDesignable public class SmallLabelDark: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension SmallLabelDark: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.footnote
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 15
@IBDesignable public class FieldLabelDarkRight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension FieldLabelDarkRight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline
        textColor = styles.colors.text.fieldDark.color
        textAlignment = .right
    }
}

/// 20
@IBDesignable public class TitleLabelMarkerBlue: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension TitleLabelMarkerBlue: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.marker.title3
        textColor = styles.colors.buttons.primaryDark.fill.color
        textAlignment = .center
    }
}

/// 20
@IBDesignable public class TitleLabelBlue: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension TitleLabelBlue: Stylable {
    public func apply(styles: AppStyles) {
        font = UIFont(descriptor: UIFontDescriptor().withSymbolicTraits([.traitItalic])!, size: styles.fonts.sansSerif.title3.pointSize)
        textColor = styles.colors.buttons.primaryDark.fill.color
        textAlignment = .center
    }
}

/// 20
@IBDesignable public class TitleLabelBlueLeft: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension TitleLabelBlueLeft: Stylable {
    public func apply(styles: AppStyles) {
        font = UIFont(descriptor: UIFontDescriptor().withSymbolicTraits([.traitBold, .traitItalic])!, size: styles.fonts.sansSerif.title3.pointSize)
        textColor = styles.colors.buttons.primaryDark.fill.color
        textAlignment = .left
    }
}

/// 17
@IBDesignable public class FieldLabelBoldDark: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .headline).bold
    }
}

extension FieldLabelBoldDark: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.headline.bold
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 17
@IBDesignable public class FieldLabelBoldLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .headline).bold
    }
}

extension FieldLabelBoldLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.headline.bold
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 20
@IBDesignable public class HeadingLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension HeadingLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 20
@IBDesignable public class HeadingLabelBoldLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension HeadingLabelBoldLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3.bold
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 20
@IBDesignable public class HeadingLabelDark: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension HeadingLabelDark: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 17
@IBDesignable public class BodyLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .body)
    }
}

extension BodyLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.body
        textColor = styles.colors.text.info.color
    }
}

/// 17
@IBDesignable public class SubTitleLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .body)
    }
}

extension SubTitleLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.body
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 17
@IBDesignable public class BodyLabelDark: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .body)
    }
}

extension BodyLabelDark: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.body
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 17
@IBDesignable public class BodyLabelDarkSemiBold: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .body)
    }
}

extension BodyLabelDarkSemiBold: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.body.semiBold
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 17
@IBDesignable public class BodyLabelLightSemiBold: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .body)
    }
}

extension BodyLabelLightSemiBold: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.body.semiBold
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 20
@IBDesignable public class LabelBlue: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title3)
    }
}

extension LabelBlue: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3
        textColor = styles.colors.buttons.primaryDark.fill.color
    }
}

/// 15
@IBDesignable public class InfoLabel: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.darkGray
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension InfoLabel: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.subheadline
        textColor = styles.colors.text.info.color
    }
}

/// 28
@IBDesignable public class DashboardLargeLabel: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension DashboardLargeLabel: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title1
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 32
@IBDesignable public class BudgetLargeLabel: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension BudgetLargeLabel: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.largeTitle
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 32
@IBDesignable public class DashboardLargeTitle: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .subheadline)
    }
}

extension DashboardLargeTitle: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.largeTitle
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 17
@IBDesignable public class HeadlineLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .headline)
    }
}

extension HeadlineLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.headline
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 17
@IBDesignable public class HeadlineLabelDark: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .headline)
    }
}

extension HeadlineLabelDark: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.headline
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 20
@IBDesignable public class HeadingTotalLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.black
        font = UIFont.preferredFont(forTextStyle: .title3).light
    }
}

extension HeadingTotalLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3.light
        textColor = styles.colors.text.fieldLight.color
    }
}

/// 22
@IBDesignable public class HeadingTitleLabel: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title2).semiBold
    }
}

extension HeadingTitleLabel: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title2.semiBold
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 22
@IBDesignable public class HeadingTitleLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title2).light
    }
}

extension HeadingTitleLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title2.light
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 20
@IBDesignable public class HeadingLabelInfo: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.white
        font = UIFont.preferredFont(forTextStyle: .title3).medium
    }
}

extension HeadingLabelInfo: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3.medium
        textColor = styles.colors.text.fieldDark.color
    }
}

/// 20
@IBDesignable public class HeadingTotalLabelInfo: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.darkGray
        font = UIFont.preferredFont(forTextStyle: .title3).light
    }
}

extension HeadingTotalLabelInfo: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.title3.light
        textColor = styles.colors.text.info.color
    }
}

/// 17
@IBDesignable public class TotalLabelLight: StandardLabel {
    override func defaultSetup() {
        textColor = UIColor.darkGray
        font = UIFont.preferredFont(forTextStyle: .headline)
    }
}

extension TotalLabelLight: Stylable {
    public func apply(styles: AppStyles) {
        font = styles.fonts.sansSerif.headline
        textColor = styles.colors.text.info.color
    }
}
