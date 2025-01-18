//
//  SavingBudgetTablewViewHeader.swift
//  AffordIQUI
//
//  Created by Asilbek Djamaldinov on 07/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQControls
import AffordIQFoundation

class SavingBudgetTablewViewHeader: UITableViewHeaderFooterView, Stylable {
    private(set) lazy var whiteOverlayHeadingLabel: HeadingLabelBoldLight = {
        let view = HeadingLabelBoldLight()
        view.text = "Set a Budget"
        view.textAlignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var infoLabel: InfoLabel = {
        let view = InfoLabel()
        view.text = "Set spending targets below to increase your monthly savings and complete your goal sooner."
        view.textAlignment = .left
        view.numberOfLines = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var whiteOverlayStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    func setup() {
        setupSubviews()
    }
}

extension SavingBudgetTablewViewHeader: AnyConstraintView {
    func embedSubviews() {
        contentView.addSubview(whiteOverlayStackView)
        
        whiteOverlayStackView.addArrangedSubview(whiteOverlayHeadingLabel)
        whiteOverlayStackView.addArrangedSubview(infoLabel)
    }
    
    func setupSubviewsConstraints() {
        whiteOverlayStackView.embedToView(contentView, padding: 8)
    }
}
