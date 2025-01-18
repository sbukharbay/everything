//
//  JourneyPageCell.swift
//  AffordIQUI
//
//  Created by Ashley Oldham on 05/10/2021.
//  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit
import SafariServices

final class JourneyPageCell: UICollectionViewCell, ReusableElement, Stylable {
    let infoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var headerLabel: TitleLabelMarkerBlue = .init()

    private let descriptionLabel: TermsConditionTextView = {
        let textView = TermsConditionTextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        textView.textColor = .white
        
        return textView
    }()

    private lazy var blurEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var termsTextView: TermsConditionTextView = {
        let textView = TermsConditionTextView()
        
        let text = "For Adviser fee, please refer to section 17 on our Terms and Conditions"
        let termsRange = (text as NSString).range(of: "Terms and Conditions")
        let termsURL = URL(string: "https://app.termly.io/document/terms-of-use-for-ios-app/87c4cc74-6413-4956-b48f-eccab3963fd3")!
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.link, value: termsURL, range: termsRange)
        
        textView.attributedText = attributedString
        textView.tintColor = UIColor(hex: "#72F0F0")
        textView.textAlignment = .left
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        return textView
    }()
    
    private(set) lazy var mabLogoImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "mab_logo", in: uiBundle, compatibleWith: nil)
        view.contentMode = .scaleAspectFit
        view.isHidden = true
        
        return view
    }()

    static var reuseIdentifier: String = "JourneyPage"
    private var isLast: Bool!
    private var onClick: ((SFSafariViewController) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        [blurEffectView, headerLabel, infoImageView, descriptionLabel, termsTextView, mabLogoImageView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        var constraintsToActivate: [NSLayoutConstraint] = []
        constraintsToActivate.append(contentsOf: [
            blurEffectView.topAnchor.constraint(equalTo: topAnchor, constant: 60),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),

            headerLabel.topAnchor.constraint(equalTo: blurEffectView.topAnchor, constant: 16),
            headerLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            headerLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32),
            headerLabel.bottomAnchor.constraint(equalTo: infoImageView.topAnchor, constant: -8),

            infoImageView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 40),
            infoImageView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -40),
            infoImageView.heightAnchor.constraint(equalToConstant: isLast ? frame.height / 4 : frame.height / 2.4),
            
            descriptionLabel.topAnchor.constraint(equalTo: infoImageView.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32),
            
            termsTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            termsTextView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 32),
            termsTextView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -32),
            
            mabLogoImageView.topAnchor.constraint(lessThanOrEqualTo: termsTextView.bottomAnchor, constant: 16),
            mabLogoImageView.leadingAnchor.constraint(equalTo: blurEffectView.leadingAnchor, constant: 40),
            mabLogoImageView.trailingAnchor.constraint(equalTo: blurEffectView.trailingAnchor, constant: -40),
            mabLogoImageView.heightAnchor.constraint(equalToConstant: frame.height * 0.07)
        ])
        
        NSLayoutConstraint.activate(constraintsToActivate)
    }

    func setup(page: Page, styles: AppStyles, isLast: Bool, onClick: @escaping (SFSafariViewController) -> Void) {
        infoImageView.image = UIImage(named: page.imageName, in: uiBundle, compatibleWith: nil)
        headerLabel.text = page.headerText
        descriptionLabel.text = page.bodyText
        mabLogoImageView.isHidden = !isLast
        termsTextView.isHidden = !isLast
        self.isLast = isLast
        self.onClick = onClick
        
        setupLayout()

        apply(styles: styles)
    }
}

extension JourneyPageCell: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariViewController = SFSafariViewController(url: URL)
        safariViewController.modalPresentationStyle = .popover
        
        onClick?(safariViewController)
        
        return false
    }
}
