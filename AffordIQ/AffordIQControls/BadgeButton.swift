//
//  BadgeButton.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 07/05/2020.
//  Copyright © 2022 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit
import AffordIQFoundation

public class BadgeButton: UIButton {
    public var badgeLabel = UILabel()
    
    public var badge: String? {
        didSet {
            addBadgeToButton(badge: badge)
        }
    }
    
    public var badgeBackgroundColor: UIColor = UIColor.primaryColor {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    public var badgeTextColor = UIColor.black {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    public var badgeFont = UIFont.systemFont(ofSize: 12.0) {
        didSet {
            badgeLabel.font = badgeFont
        }
    }
    
    public var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            addBadgeToButton(badge: badge)
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addBadgeToButton(badge: nil)
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(
            x: self.bounds.origin.x - 10.0,
            y: self.bounds.origin.y - 10.0,
            width: self.bounds.size.width + 30.0,
            height: self.bounds.size.height + 50.0
        )
        return newArea.contains(point)
    }
    
    public func addBadgeToButton(badge: String?) {
        badgeLabel.text = badge
        badgeLabel.textColor = badgeTextColor
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.font = badgeFont
        badgeLabel.sizeToFit()
        badgeLabel.textAlignment = .center
        badgeLabel.isUserInteractionEnabled = false
        let badgeSize = badgeLabel.frame.size
        
        let height = max(16, Double(badgeSize.height) + 4.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)
            
            let xAxis = (Double(bounds.size.width) - 30 + horizontal!)
            let yAxis = -(Double(badgeSize.height) / 2) - 30 + vertical!
            badgeLabel.frame = CGRect(x: xAxis, y: yAxis, width: width, height: height)
        } else {
            let xAxis = self.frame.width - CGFloat(width * 2 / 3)
            let yAxis: CGFloat = -3
            badgeLabel.frame = CGRect(x: xAxis, y: yAxis, width: CGFloat(width), height: CGFloat(height))
        }
        
        badgeLabel.layer.cornerRadius = badgeLabel.frame.height / 2
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        badgeLabel.isHidden = badge != nil ? false : true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addBadgeToButton(badge: nil)
        fatalError("init(coder:) has not been implemented")
    }
}
