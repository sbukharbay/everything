//
//  AppStyles.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 27/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public protocol Stylable: AnyObject {
    func apply(styles: AppStyles)
}

public extension Stylable where Self: UIViewController {
    func apply(styles: AppStyles) {
        view.style(styles: styles)
        navigationController?.navigationBar.apply(styles: styles)
    }
}

public extension Stylable where Self: UITableViewCell {
    func apply(styles: AppStyles) {
        contentView.style(styles: styles)
    }
}

public extension Stylable where Self: UITableViewHeaderFooterView {
    func apply(styles: AppStyles) {
        contentView.style(styles: styles)
    }
}

public extension Stylable where Self: UICollectionViewCell {
    func apply(styles: AppStyles) {
        contentView.style(styles: styles)
    }
}

public extension UIFont {
    func fontWith(weight: UIFont.Weight) -> UIFont {
        var attributes = fontDescriptor.fontAttributes
        attributes[.name] = nil
        attributes[.traits] = [UIFontDescriptor.TraitKey.weight: weight]
        attributes[.family] = familyName

        let descriptor = UIFontDescriptor(fontAttributes: attributes)

        return UIFont(descriptor: descriptor, size: fontDescriptor.pointSize)
    }

    var ultralight: UIFont {
        return fontWith(weight: .ultraLight)
    }

    var thin: UIFont {
        return fontWith(weight: .thin)
    }

    var light: UIFont {
        return fontWith(weight: .light)
    }

    var regular: UIFont {
        return fontWith(weight: .regular)
    }

    var medium: UIFont {
        return fontWith(weight: .medium)
    }

    var semiBold: UIFont {
        return fontWith(weight: .semibold)
    }

    var bold: UIFont {
        return fontWith(weight: .bold)
    }

    var heavy: UIFont {
        return fontWith(weight: .heavy)
    }

    var black: UIFont {
        return fontWith(weight: .black)
    }
}

public extension UIView {
    func style(styles: AppStyles) {
        if let stylable = self as? Stylable {
            stylable.apply(styles: styles)
        }
        subviews.forEach {
            $0.style(styles: styles)
        }
    }
}

public struct AppStyles: Codable {
    public struct CodableColor: Codable {
        public let color: UIColor

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let hex = try container.decode(String.self)
            color = UIColor(hex: hex)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            let hex = color.hex
            try container.encode(hex)
        }
    }

    public struct Fonts: Codable {
        enum CodingKeys: String, CodingKey {
            case sansSerif
            case serif
            case monospace
            case rounded
            case redacted
            case marker
        }

        public let sansSerif: FontBook
        public let serif: FontBook
        public let monospace: FontBook
        public let rounded: FontBook
        public let redacted: FontBook
        public let marker: FontBook
    }

    public struct Button: Codable {
        public let text: CodableColor
        public let disabledText: CodableColor
        public let highlightedText: CodableColor
        public let fill: CodableColor
        public let border: CodableColor
        public let disabledFill: CodableColor
        public let disabledBorder: CodableColor
        public let highlightedFill: CodableColor
        public let highlightedBorder: CodableColor
    }

    public struct TextColors: Codable {
        public let error: CodableColor
        public let fieldLight: CodableColor
        public let fieldDark: CodableColor
        public let info: CodableColor
    }

    public struct Field: Codable {
        public let fill: CodableColor
        public let placeholder: CodableColor
        public let text: CodableColor
        public let focusedBorder: CodableColor
        public let focusedErrorBorder: CodableColor
    }

    public struct FieldColors: Codable {
        public let light: Field
        public let dark: Field
    }

    public struct Buttons: Codable {
        public let primaryDark: Button
        public let secondaryDark: Button
        public let primaryLight: Button
        public let secondaryLight: Button
        public let inlineLight: Button
        public let inlineDark: Button
        public let darkBlue: Button
        public let inlineWhite: Button
        public let clearDarkTeal: Button
        public let warningDark: Button
    }

    public struct GradientColors: Codable {
        public let spending: [CodableColor]
        public let income: [CodableColor]
    }

    public struct Colors: Codable {
        public let text: TextColors
        public let fields: FieldColors
        public let buttons: Buttons
        public let cells: CellsColors
        public let gradients: GradientColors
    }

    public struct CellColors: Codable {
        public let sectionTitle: CodableColor
        public let background: CodableColor
        public let accessory: CodableColor
        public let title: CodableColor
        public let detail: CodableColor
    }

    public struct CellsColors: Codable {
        public let account: CellColors
        public let overlay: CellColors
    }

    public struct BackgroundImage: Codable {
        public let name: String

        public var image: UIImage {
            return UIImage(named: name, in: Bundle.main, compatibleWith: nil)!
        }

        public var imageView: UIImageView {
            let loadedImage = image
            let newImageView = UIImageView(image: loadedImage)
            newImageView.frame = CGRect(origin: CGPoint.zero, size: loadedImage.size)
            newImageView.contentMode = .scaleAspectFill
            newImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            return newImageView
        }
    }

    public struct BackgroundImages: Codable {
        enum CodingKeys: String, CodingKey {
            case defaultImage = "default"
        }

        public let defaultImage: BackgroundImage
    }

    public let fonts: Fonts
    public let colors: Colors
    public let backgroundImages: BackgroundImages
    
    public static let shared = AppStyles.named("AppStyles")
    
    public static func named(_ name: String, bundle: Bundle = Bundle.main) -> AppStyles {
        do {
            let url = bundle.url(forResource: name, withExtension: "json")
            let data = try Data(contentsOf: url!)
            let decoder = JSONDecoder()
            decoder.dataDecodingStrategy = .base64
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(AppStyles.self, from: data)
        } catch {
            fatalError("Unable to start: \(error)")
        }
    }
}

extension UINavigationBar: Stylable {
    public func apply(styles: AppStyles) {
        barStyle = .black
        let attributes: [NSAttributedString.Key: Any] = [
            .font: styles.fonts.sansSerif.title3,
            .foregroundColor: UIColor.white
        ]
        titleTextAttributes = attributes

        let barItemAttributes: [NSAttributedString.Key: Any] = [
            .font: styles.fonts.sansSerif.body
        ]

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes(barItemAttributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes(barItemAttributes, for: .highlighted)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setTitleTextAttributes(barItemAttributes, for: .disabled)

        subviews
            .compactMap { $0 as? Stylable }
            .forEach { $0.apply(styles: styles) }
    }
}

extension UIToolbar: Stylable {
    public func apply(styles: AppStyles) {
        barStyle = .black

        let barItemAttributes: [NSAttributedString.Key: Any] = [
            .font: styles.fonts.sansSerif.body
        ]

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).setTitleTextAttributes(barItemAttributes, for: .normal)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).setTitleTextAttributes(barItemAttributes, for: .highlighted)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).setTitleTextAttributes(barItemAttributes, for: .disabled)
    }
}

extension UISearchBar: Stylable {
    public func apply(styles: AppStyles) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: styles.fonts.sansSerif.body,
            .foregroundColor: UIColor.white
        ]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attributes
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = styles.fonts.sansSerif.body
    }
}

public class FontBook: Codable {
    enum CodingKeys: String, CodingKey {
        case familyName
        case scale
    }

    let familyName: String?
    let scale: CGFloat?
    let systemDesign: UIFontDescriptor.SystemDesign
    var fontCache: [UIFont.TextStyle: UIFont] = [:]

    public var largeTitle: UIFont { return font(textStyle: .largeTitle) }
    public var title1: UIFont { return font(textStyle: .title1) }
    public var title2: UIFont { return font(textStyle: .title2) }
    public var title3: UIFont { return font(textStyle: .title3) }
    public var headline: UIFont { return font(textStyle: .headline) }
    public var subheadline: UIFont { return font(textStyle: .subheadline) }
    public var body: UIFont { return font(textStyle: .body) }
    public var callout: UIFont { return font(textStyle: .callout) }
    public var footnote: UIFont { return font(textStyle: .footnote) }
    public var caption1: UIFont { return font(textStyle: .caption1) }
    public var caption2: UIFont { return font(textStyle: .caption2) }

    private func buildCache(design: UIFontDescriptor.SystemDesign) {
        fontCache.removeAll()

        let textStyles: [UIFont.TextStyle] = [.largeTitle, .title1, .title2, .title3,
                                              .headline, .subheadline,
                                              .body, .callout, .footnote,
                                              .caption1, .caption2]

        guard let familyName = familyName, !familyName.isEmpty else {
            for textStyle in textStyles {
                if let designDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle).withDesign(design) {
                    let scale = self.scale ?? 1.0
                    fontCache[textStyle] = UIFont(descriptor: designDescriptor, size: designDescriptor.pointSize * scale)
                } else {
                    fontCache[textStyle] = UIFont.preferredFont(forTextStyle: textStyle)
                }
            }
            return
        }

        for textStyle in textStyles {
            let sourceDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)

            if let targetDescriptor = UIFontDescriptor()
                .withFamily(familyName)
                .withSymbolicTraits(sourceDescriptor.symbolicTraits) {
                let scale = self.scale ?? 1.0
                fontCache[textStyle] = UIFont(descriptor: targetDescriptor, size: sourceDescriptor.pointSize * scale)
            } else {
                debugPrint("⚠️ Unable to create a custom font for \(familyName) with symbolicTraits \(sourceDescriptor.symbolicTraits), falling back to system font.")
                fontCache[textStyle] = UIFont.preferredFont(forTextStyle: textStyle)
            }
        }
    }

    private func font(textStyle: UIFont.TextStyle) -> UIFont {
        return fontCache[textStyle]!
    }

    private static func systemDesign(for key: AppStyles.Fonts.CodingKeys) -> UIFontDescriptor.SystemDesign {
        switch key {
        case .monospace:
            return .monospaced
        case .serif:
            return .serif
        case .rounded:
            return .rounded
        case .sansSerif:
            return .default
        case .redacted:
            return .default
        case .marker:
            return .default
        }
    }

    public init(familyName: String, systemDesign: UIFontDescriptor.SystemDesign, scale: CGFloat? = nil) {
        self.familyName = familyName
        self.systemDesign = systemDesign
        self.scale = scale
        buildCache(design: systemDesign)

        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryUpdated(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let codingKey = container.codingPath.last as? AppStyles.Fonts.CodingKeys else {
            fatalError("Unable to determine coding key.")
        }

        familyName = try container.decodeIfPresent(String.self, forKey: .familyName)
        scale = try container.decodeIfPresent(CGFloat.self, forKey: .scale)
        systemDesign = FontBook.systemDesign(for: codingKey)
        buildCache(design: systemDesign)

        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryUpdated(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    @objc func contentSizeCategoryUpdated(_: Any?) {
        buildCache(design: systemDesign)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    // swiftlint:disable:next file_length
}
