//
//  Dictionary+Extensions.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 28/04/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

public extension Dictionary {
    static func from<K: Hashable, V>(zip: Zip2Sequence<[K], [V]>) -> [K: V] {
        var result = [K: V].init(minimumCapacity: zip.underestimatedCount)

        zip.forEach { result[$0.0] = $0.1 }

        return result
    }
}

public extension Dictionary where Key == NSAttributedString.Key, Value: Any {
    static func + (lhs: Self, rhs: Self) -> Self {
        return lhs.merging(rhs, uniquingKeysWith: { $1 })
    }
    
    static var missingValuePlaceholder: String {
        NSLocalizedString("-", bundle: Bundle.main,
                          comment: "Placeholder for missing values")
    }
}
