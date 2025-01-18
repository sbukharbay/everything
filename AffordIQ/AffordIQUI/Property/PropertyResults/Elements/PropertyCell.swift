//
//  PropertyCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 29/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import SDWebImage
import UIKit

class PropertyCell: UITableViewCell, TableViewElement, PropertyCellBoundView {
    @IBOutlet var clipView: UIView?

    @IBOutlet var headline: UILabel?
    @IBOutlet var body: UILabel?
    @IBOutlet var thumbnail: UIImageView?
    @IBOutlet var affordabilityProgress: CircularMeterView?
    @IBOutlet var affordabilityDescription: UILabel?
    @IBOutlet var bubbleBackground: UIView?

    var viewModel: PropertyCellViewModel?

    var styled = false
    static var reuseIdentifier: String = "PropertyCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        if let clipLayer = clipView?.layer {
            clipLayer.cornerRadius = 4.0
            clipLayer.masksToBounds = true
        }
    }

    @IBAction func openDetails(_: Any?) {
        if let tableView = superview as? UITableView,
           let indexPath = tableView.indexPath(for: self) {
            tableView.delegate?.tableView?(tableView, accessoryButtonTappedForRowWith: indexPath)
        }
    }
}

extension PropertyCell: Stylable {
    func apply(styles: AppStyles) {
        contentView.style(styles: styles)
        bubbleBackground?.backgroundColor = styles.colors.buttons.primaryLight.fill.color
    }
}
