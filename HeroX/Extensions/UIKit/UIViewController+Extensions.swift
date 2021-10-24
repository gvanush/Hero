//
//  UIViewController+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/19/21.
//

import UIKit

@nonobjc extension UIViewController {
    
    func installViewController(_ viewController: UIViewController, viewSetup: (UIView) -> Void) {
        assert(viewController.parent == nil)
        addChild(viewController)
        viewSetup(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func uninstallViewController(_ viewController: UIViewController) {
        assert(viewController.parent == self)
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    var isVisible: Bool {
        isViewLoaded && view.window != nil
    }
    
}
