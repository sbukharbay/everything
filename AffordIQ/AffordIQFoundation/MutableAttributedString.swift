//
//  MutableString.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 01.11.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension NSMutableAttributedString {
    func style(_ value: String, font: UIFont) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]

        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func orangeHighlight(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.orange
        ]

        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func blackHighlight(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.black
        ]

        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func underlined(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        append(NSAttributedString(string: value, attributes: attributes))
        return self
    }
}
