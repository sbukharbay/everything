//
//  BackgroundImageView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 18/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

@IBDesignable public class BackgroundImageView: UIImageView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        contentMode = .scaleAspectFill
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        image = UIImage(named: "design_time_background", in: Bundle(for: BackgroundImageView.self), compatibleWith: nil)
    }
}

extension BackgroundImageView: Stylable {
    public func apply(styles: AppStyles) {
        image = styles.backgroundImages.defaultImage.image
    }
}
