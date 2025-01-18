//
//  KeywordSearch.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 04/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

public protocol Searchable {
    var searchFields: [String] { get }
}

public func search<T: Searchable>(for filter: String?,
                                  in values: [T],
                                  options: String.CompareOptions = [.diacriticInsensitive, .caseInsensitive],
                                  locale: Locale = Locale.autoupdatingCurrent) -> [T] {
    guard let filter = filter?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
          !filter.isEmpty
    else {
        return values
    }

    let filterWords = filter.components(separatedBy: CharacterSet.whitespaces)
        .filter { !$0.isEmpty }
        .map { $0.folding(options: options, locale: locale) }

    guard !filterWords.isEmpty else {
        return values
    }

    return values.filter { value in

        let words = value.searchFields
            .joined(separator: " ")
            .components(separatedBy: CharacterSet.whitespaces)
            .filter { !$0.isEmpty }
            .map { $0.folding(options: options, locale: locale) }

        return filterWords.allSatisfy { filterWord -> Bool in

            words.contains { $0.hasPrefix(filterWord)
            }
        }
    }
}
