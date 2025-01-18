//
//  ContentSizeMonitor.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 27/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

@objc public protocol ContentSizeMonitorDelegate: AnyObject {
    func contentSizeCategoryUpdated()
}

public class ContentSizeMonitor: NSObject {
    @IBOutlet public weak var delegate: ContentSizeMonitorDelegate?

    override public init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryUpdated(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    @objc func contentSizeCategoryUpdated(_: Any?) {
        delegate?.contentSizeCategoryUpdated()
    }

    deinit {
        removeObserver()
    }

    public func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}
