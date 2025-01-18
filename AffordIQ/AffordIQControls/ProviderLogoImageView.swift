//
//  ProviderLogoImageView.swift
//  AffordIQControls
//
//  Created bySultangazy Bukharbay on 03/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import SDWebImage
import SDWebImageSVGCoder
import UIKit

public class ProviderLogoImageView: UIImageView {
    private static var initialized = false

    public var imageURL: URL? {
        didSet {
            if !ProviderLogoImageView.initialized {
                ProviderLogoImageView.initialized = true

                let svgCoder = SDImageSVGCoder.shared
                SDImageCodersManager.shared.addCoder(svgCoder)
            }

            sd_setImage(with: imageURL)
        }
    }
}
