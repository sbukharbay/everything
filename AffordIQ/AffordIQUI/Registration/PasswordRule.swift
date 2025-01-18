//
//  PasswordRule.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27/04/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public enum PasswordRule {
    public enum CharacterClass {
        case upper, lower, digits, special, asciiPrintable, unicode

        case custom(Set<Character>)
    }

    case required(CharacterClass)

    case allowed(CharacterClass)

    case maxConsecutive(UInt)

    case minLength(UInt)

    case maxLength(UInt)
}

public struct PasswordRules {
    public var rules: [PasswordRule]
}

public extension String {
    var maxConsecutive: Int {
        var previous: Character?
        var count = 0
        var maxCount = 0

        forEach { current in

            if current == previous {
                count += 1
                maxCount = max(maxCount, count)
            } else {
                count = 1
            }
            previous = current
        }

        return maxCount
    }
}

public extension CharacterSet {
    func contains(anyCharacterFrom string: String) -> Bool {
        let characters = Set(string)

        for character in characters {
            for unicodeScalar in character.unicodeScalars where contains(unicodeScalar) {
                return true
            }
        }

        return false
    }
}

extension PasswordRules {
    private func contains(characterClass: PasswordRule.CharacterClass, in password: String) -> Bool {
        switch characterClass {
        case .upper:
            return CharacterSet.uppercaseLetters.contains(anyCharacterFrom: password)

        case .lower:
            return CharacterSet.lowercaseLetters.contains(anyCharacterFrom: password)

        case .digits:
            return CharacterSet.decimalDigits.contains(anyCharacterFrom: password)

        case .special:
            return CharacterSet.punctuationCharacters.contains(anyCharacterFrom: password)

        case .asciiPrintable:
            return !(password.data(using: .ascii)?.isEmpty ?? true)

        case .unicode:
            return !(password.data(using: .unicode)?.isEmpty ?? true)

        case let .custom(characters):
            return !characters.isDisjoint(with: Set(password))
        }
    }

    public func validate(password: String) -> Bool {
        for rule in rules {
            switch rule {
            case let .required(characterClass):
                if !contains(characterClass: characterClass, in: password) {
                    return false
                }

            case .allowed:
                break

            case let .maxConsecutive(maxConsecutive):
                if password.maxConsecutive > maxConsecutive {
                    return false
                }

            case let .minLength(minLength):
                if password.count < minLength {
                    return false
                }
            case let .maxLength(maxLength):
                if password.count > maxLength {
                    return false
                }
            }
        }
        return true
    }

    var stringRepresentation: String {
        rules.map { "\($0.description);" }
            .joined(separator: " ")
    }
}

extension PasswordRule: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .required(characterClass):
            return "required: \(characterClass)"

        case let .allowed(characterClass):
            return "allowed: \(characterClass)"

        case let .maxConsecutive(length):
            return "max-consecutive: \(length)"

        case let .minLength(length):
            return "minlength: \(length)"

        case let .maxLength(length):
            return "maxlength: \(length)"
        }
    }
}

extension PasswordRule.CharacterClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .upper:
            return "upper"

        case .lower:
            return "lower"

        case .digits:
            return "digits"

        case .special:
            return "special"

        case .asciiPrintable:
            return "ascii-printable"

        case .unicode:
            return "unicode"

        case let .custom(characters):
            return "[" + String(characters) + "]"
        }
    }
}
