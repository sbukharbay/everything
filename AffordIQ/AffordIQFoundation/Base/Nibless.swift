//
//  Nibless.swift
//  AffordIQFoundation
//
//  Created by Sultangazy Bukharbay on 05/09/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

open class NiblessViewController: UIViewController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("This method should not be called")
    }
}

open class NiblessNavigationController: UINavigationController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("This method should not be called")
    }
}

open class NiblessView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("This method should not be called")
    }
}

open class NiblessTabBarController: UITabBarController {
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("This method should not be called")
    }
}

open class NiblessTableViewCell: UITableViewCell {
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("This method should not be called")
    }
}
