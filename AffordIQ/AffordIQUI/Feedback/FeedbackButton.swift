//
//  FeedbackButton.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 27.04.2022.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public class FloatingButtonController: UIViewController {
    public lazy var feedbackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("F\nE\nE\nD\nB\nA\nC\nK", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(hex: "0F0728")
        button.layer.cornerRadius = 8
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        button.layer.borderColor = UIColor(hex: "72F0F0").cgColor
        button.layer.borderWidth = 1
        button.titleLabel?.lineBreakMode = .byCharWrapping
        button.titleLabel?.textAlignment = .center
        button.setImage(UIImage(systemName: "text.bubble"), for: .normal)
        button.imageView?.tintColor = UIColor(hex: "72F0F0")
        button.contentVerticalAlignment = .center
        button.alignVertical()
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize.zero
        button.addTarget(self, action: #selector(handleFeedback), for: .touchUpInside)
        return button
    }()

    private var className = ""

    override public func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        [feedbackButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            feedbackButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            feedbackButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            feedbackButton.heightAnchor.constraint(equalToConstant: 240),
            feedbackButton.widthAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    public func hideFeedbackButton() {
        feedbackButton.isHidden = true
    }

    public func bringFeedbackButton(
        _ className: String
    ) {
        view.bringSubviewToFront(feedbackButton)
        self.className = className
    }

    @objc private func handleFeedback() {
        if let presenter = navigationController {
            presenter.dismiss(animated: true, completion: {
                let coordinator = FeedbackFormCoordinator(presenter: presenter, className: self.className)
                coordinator.start()
            })
        }
    }
    
    func setupSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swiped))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
    }
    
    @objc
    func swiped(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if let index = tabBarController?.selectedIndex, index < 3 {
                tabBarController?.selectedIndex += 1
            }
        } else if gesture.direction == .right {
            if let index = tabBarController?.selectedIndex, index > 0 {
                tabBarController?.selectedIndex -= 1
            }
        }
    }
    
    deinit {
        print("\(String(describing: self)) cleaned from memory")
    }
}

extension UIButton {
    func alignVertical(spacing: CGFloat = 6.0) {
        guard let imageSize = imageView?.image?.size,
              let text = titleLabel?.text,
              let font = titleLabel?.font
        else { return }
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [kCTFontAttributeName as NSAttributedString.Key: font])
        imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
        contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }
}

extension FloatingButtonController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
