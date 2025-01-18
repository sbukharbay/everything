//
//  UITableView+Extensions.swift
//  AffordIQFoundation
//
//  Created by Asilbek Djamaldinov on 11/08/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: cellClass.identifier)
    }
    
    func register<T: UITableViewHeaderFooterView>(_ headerFooterCLass: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
    }
    
    // swiftlint:disable force_cast
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: cellClass.identifier, for: indexPath) as! T
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(_ headerFooterCLass: T.Type) -> T {
        dequeueReusableHeaderFooterView(withIdentifier: headerFooterCLass.identifier) as! T
    }
    // swiftlint:enable force_cast
}
