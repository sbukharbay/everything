//
//  UIColor+Hex.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 26/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension UIColor {
    var hex: String {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        var stringValue = "#"
        stringValue.append(String(format: "%X", Int(red * 255.0)))
        stringValue.append(String(format: "%X", Int(green * 255.0)))
        stringValue.append(String(format: "%X", Int(blue * 255.0)))
        if alpha < 1.0 {
            stringValue.append(String(format: "%X", Int(alpha * 255.0)))
        }

        return stringValue
    }

    convenience init(hex: String) {
        var red: CGFloat
        var green: CGFloat
        var blue: CGFloat
        var alpha: CGFloat

        var hexString = hex.trimmingCharacters(in: CharacterSet.punctuationCharacters)
        if hexString.count == 6 {
            hexString.append("FF")
        }

        if hexString.count == 8 {
            let scanner = Scanner(string: hexString)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                red = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255.0
                green = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255.0
                blue = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255.0
                alpha = CGFloat(hexNumber & 0x0000_00FF) / 255.0

                self.init(red: red, green: green, blue: blue, alpha: alpha)
                return
            }
        }

        fatalError("Unable to parse hex color: \(hexString)")
    }
}
