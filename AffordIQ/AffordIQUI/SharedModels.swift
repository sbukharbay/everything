//
//  SharedModels.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 22/10/2020.
//  Copyright © 2020 BlackArrow Financial Solutions Limited. All rights reserved.
//

import AffordIQControls
import AffordIQFoundation
import UIKit

public protocol ViewController: AnyObject {
    func perform(action: (UIViewController) -> Void)
}

public protocol ErrorPresenter: AnyObject {
    func present(error: Error)
    func present(error: Error, completion: (() -> Void)?)
}

public protocol DefaultDependenciesType {
    var session: SessionType { get }
    var styles: AppStyles { get }
}

public extension ViewController where Self: UIViewController {
    func perform(action: (UIViewController) -> Void) {
        action(self)
    }
}

public extension ErrorPresenter where Self: UIViewController {
    func present(error: Error) {
        asyncIfRequired {
            self.present(error: error, completion: nil)
        }
    }

    func present(error: Error, completion: (() -> Void)?) {
        #if DEBUG
            print(error)
        #endif
        asyncIfRequired {
            self.view.isUserInteractionEnabled = true
            UIAlertController.present(error: error, from: self, completion: completion)
        }
    }
}

public extension ErrorPresenter where Self: UITabBarController {
    func present(error: Error) {
        present(error: error, completion: nil)
    }

    func present(error: Error, completion: (() -> Void)?) {
        #if DEBUG
            print(error)
        #endif
        asyncIfRequired {
            UIAlertController.present(error: error, from: self, completion: completion)
        }
    }
}

public protocol Coordinator: AnyObject {
    func start()
}

public protocol ResumableCoordinator: Coordinator {
    func resume()
}

public protocol DashboardResumableCoordinator: ResumableCoordinator {
    var tabBarItem: UITabBarItem { get }
}

public protocol StoryboardInstantiable: AnyObject {
    static func instantiate(storyboard: String, identifier: String?) -> Self?
    static func instantiate() -> Self?
}

public extension StoryboardInstantiable where Self: UIViewController {
    static func instantiate(storyboard: String, identifier: String?) -> Self? {
        let storyboard = UIStoryboard(name: storyboard, bundle: Bundle(for: Self.self))
        var result: Self?

        if let identifier = identifier {
            result = storyboard.instantiateViewController(identifier: identifier) as? Self
        } else {
            result = storyboard.instantiateInitialViewController() as? Self
        }

        if result == nil {
            debugPrint("⚠️ Unable to load view controller of type \(Self.self) from \(storyboard) \(identifier ?? "(Initial)") - hilarity may ensue.")
        }

        return result
    }
}
