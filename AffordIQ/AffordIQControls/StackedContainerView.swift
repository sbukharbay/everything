//
//  StackedContainerView.swift
//  AffordIQControls
//
//  Created by Sultangazy Bukharbay on 08/12/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import UIKit

public protocol RepeatingFormContainer: AnyObject {
    var viewControllers: [UIViewController] { get }
    var numberOfControllers: Int { get }
    var parent: UIViewController? { get }
    var nextField: UITextField? { get }

    func nextViewController(after viewController: UIViewController) -> UIViewController?
    func addChild(viewController: UIViewController, animated: Bool)
    func removeLast()

    func rebalance(targetCount: Int, addController: (Int) -> Void)

    func layoutParent()
}

public class StackedContainerView: UIStackView, RepeatingFormContainer {
    @IBOutlet public var parent: UIViewController?
    @IBOutlet public var nextField: UITextField?

    public var viewControllers: [UIViewController] = []

    public var numberOfControllers: Int {
        return viewControllers.count
    }

    public func nextViewController(after viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController) {
            let next = viewControllers.index(index, offsetBy: 1)
            if next >= viewControllers.endIndex {
                return nil
            }
            return viewControllers[next]
        }

        return nil
    }

    public func addChild(viewController: UIViewController, animated: Bool) {
        if parent == nil {
            debugPrint("⚠️ Stacked Container View \(self) has no parent set - hilarity may ensue.")
        }

        viewControllers.append(viewController)
        addArrangedSubview(viewController.view)

        let completion: () -> Void = { [weak self] in

            viewController.view.alpha = 1.0
            viewController.didMove(toParent: self?.parent)
            self?.parent?.view.layoutIfNeeded()
            viewController.viewDidAppear(animated)
        }

        if animated {
            viewController.willMove(toParent: parent)
            viewController.viewWillAppear(animated)
            viewController.view.alpha = 0.0
            UIView.animate(withDuration: 0.5, animations: completion)
        } else {
            completion()
        }
    }

    public func removeLast() {
        guard !viewControllers.isEmpty else {
            return
        }

        if let lastSubview = arrangedSubviews.last,
           let viewController = viewControllers.first(where: { $0.view == lastSubview }) {
            viewController.willMove(toParent: nil)
            viewControllers.removeAll(where: { $0 == viewController })
            removeArrangedSubview(lastSubview)
            lastSubview.removeFromSuperview()
            viewController.didMove(toParent: nil)
            layoutIfNeeded()
        }
    }

    public func rebalance(targetCount: Int, addController: (Int) -> Void) {
        while viewControllers.count > targetCount {
            removeLast()
        }

        while viewControllers.count < targetCount {
            let index = viewControllers.count

            addController(index)

            assert(viewControllers.count == index + 1, "Unable to add a child view controller.")
        }
    }

    public func layoutParent() {
        if let parentView = parent?.view {
            UIView.animate(withDuration: 0.25, animations: {
                parentView.layoutIfNeeded()
            })
        }
    }
}
