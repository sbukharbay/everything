//
//  HomeModel.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 24.02.2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQFoundation

struct HomeModel {
    var info: String
    var isOverSpend: Bool
    var leftToSpend: MonetaryAmount
    var message: NSMutableAttributedString
}
