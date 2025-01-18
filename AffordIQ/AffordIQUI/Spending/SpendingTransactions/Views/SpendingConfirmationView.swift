//
//  SpendingConfirmationView.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 05/09/2023.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

final class SpendingConfirmationView: NiblessView {
    private(set) lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var merchantLabel: FieldLabelLight = {
        let view = FieldLabelLight()
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var paymentDateLabel: InfoLabel = {
        let view = InfoLabel()
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    private(set) lazy var costLabel: FieldLabelSubheadlineLight = {
        let view = FieldLabelSubheadlineLight()
        view.textAlignment = .right
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var merchantVStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .leading
        view.spacing = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var hStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .fill
        view.spacing = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}
