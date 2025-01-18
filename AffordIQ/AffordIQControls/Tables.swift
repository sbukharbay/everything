//
//  Tables.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 28/04/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public extension UITableView {
    func addRefreshControl() -> UIRefreshControl? {
        guard refreshControl == nil else { return refreshControl }

        let newRefreshControl = UIRefreshControl()
        refreshControl = newRefreshControl

        return newRefreshControl
    }
}

public extension UITableView {
    func deselectAll(animated: Bool = true) {
        if let selectedRows = indexPathsForSelectedRows {
            selectedRows.forEach { deselectRow(at: $0, animated: animated) }
        }
    }
}

public protocol ReusableElement: AnyObject {
    static var reuseIdentifier: String { get }
    static var nibName: String { get }
}

public protocol TableViewElement: ReusableElement {
    static func register(tableView: UITableView)
}

public protocol CollectionViewElement: ReusableElement {
    static func register(collectionView: UICollectionView)
}

public extension ReusableElement {
    static var nibName: String {
        let typeName = String(describing: self)

        return typeName
    }
}

public extension TableViewElement where Self: UITableViewCell {
    static func register(tableView: UITableView) {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: self))
        tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
}

public extension TableViewElement where Self: UITableViewHeaderFooterView {
    static func register(tableView: UITableView) {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: self))
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
    }
}

public extension CollectionViewElement where Self: UICollectionViewCell {
    static func register(collectionView: UICollectionView) {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: self))
        collectionView.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

public protocol ProviderBase {
    associatedtype SectionType: Hashable
    associatedtype ItemType: Hashable

    static var defaultSection: String { get }
}

public protocol TableDataProvider: ProviderBase {
    typealias DataSourceType = UITableViewDiffableDataSource<SectionType, ItemType>
    typealias SnapshotType = NSDiffableDataSourceSnapshot<SectionType, ItemType>

    var dataSource: DataSourceType? { get }

    func createDataSource(tableView: UITableView) -> DataSourceType
}

public protocol CollectionDataProvider: ProviderBase {
    typealias DataSourceType = UICollectionViewDiffableDataSource<SectionType, ItemType>
    typealias SnapshotType = NSDiffableDataSourceSnapshot<SectionType, ItemType>

    var dataSource: DataSourceType? { get }
}

public extension ProviderBase where Self: UIViewController {
    static var defaultSection: String { return "DEFAULT" }
}
