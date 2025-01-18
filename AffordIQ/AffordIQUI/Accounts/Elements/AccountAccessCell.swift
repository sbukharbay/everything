//
//  AccountAccessCell.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 03/02/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit
import AffordIQControls

class AccountAccessCell: UITableViewCell, TableViewElement, Stylable {
    static var reuseIdentifier = "AccountAccessCell"

    @IBOutlet var content: UILabel?

    func bind(content: String) {
        apply(styles: AppStyles.shared)

        if let contentLabel = self.content {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 8.0

            let attributes: [NSAttributedString.Key: Any] = [
                .font: contentLabel.font!,
                .foregroundColor: contentLabel.textColor!,
                .paragraphStyle: paragraphStyle
            ]
            let attributedContent = NSAttributedString(string: content, attributes: attributes)
            contentLabel.attributedText = attributedContent
        }
    }
}
