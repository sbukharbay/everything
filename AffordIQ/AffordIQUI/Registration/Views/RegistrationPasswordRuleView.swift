//
//  RegistrationPasswordRuleView.swift
//  AffordIQUI
//
//  Created by Asilbek Djamaldinov on 28/07/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

class RegistrationPasswordRuleView: UIView, AnyConstraintView {
    private(set) lazy var title: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var icon: UIImageView = {
        let image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
        
        let view = UIImageView(image: image)
        view.tintColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private(set) lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 8
        view.distribution = .fill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(rule: RegistrationPasswordRule) {
        title.text = rule.title
    }
    
    func setStatus(_ status: RegistrationPasswordRuleStatus) {
        switch status {
        case .neutral:
            let image = UIImage(systemName: "circle")?.withRenderingMode(.alwaysTemplate)
            icon.image = image
            icon.tintColor = .white
            title.textColor = .white
            
        case .fail:
            let image = UIImage(systemName: "x.circle.fill")?.withRenderingMode(.alwaysTemplate)
            let color = UIColor(hex: "FF90B0")
            icon.image = image
            icon.tintColor = color
            title.textColor = color
            
        case .pass:
            let image = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
            let color = UIColor(hex: "72F0F0")
            icon.image = image
            icon.tintColor = color
            title.textColor = color
        }
    }
    
    func embedSubviews() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(title)
    }
    
    func setupSubviewsConstraints() {
        setStackViewConstraints()
        setIconConstraints()
    }
}

enum RegistrationPasswordRule: String {
    case length = "At least 8 characters in length"
    case lowerCase = "1 lower case letter (a-z)"
    case upperCase = "1 upper case letter (A-Z)"
    case number = "1 number (0-9)"
    case repeatingChars = "No more than 2 repeating characters"
    
    var title: String {
        rawValue
    }
}

enum RegistrationPasswordRuleStatus {
    case neutral
    case fail
    case pass
}
