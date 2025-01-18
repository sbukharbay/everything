//
//  InterfaceBuilderStyles.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 19/11/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation
import UIKit

class InterfaceBuilderStyles: NSObject {
    static var styles: AppStyles? = {
        AppStyles.named("DefaultAppStyles", bundle: Bundle(for: InterfaceBuilderStyles.self))
    }()
}
