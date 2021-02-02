//
//  NavigationController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/2/21.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var childForStatusBarHidden: UIViewController? {
        topViewController
    }
    
}
