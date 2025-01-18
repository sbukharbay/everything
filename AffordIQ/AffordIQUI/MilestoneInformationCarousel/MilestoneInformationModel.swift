//
//  MilestoneInformationModel.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 09/11/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation

enum MilestoneInformationViewType: Equatable {
    case single(Page)
    case many([Page])
}

public enum CarouselViewType {
    case ownYourFinances
    case ownYourFuture
}
