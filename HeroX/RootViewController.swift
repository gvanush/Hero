//
//  RootViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/24/21.
//

import UIKit
import SwiftUI

class RootViewController: UIViewController {
    
    @IBOutlet weak var projectBar: ProjectBar!
    var rootTabBarController: UITabBarController!
    
    override func viewDidLoad() {
        projectBar.projectsButton.addTarget(self, action: #selector(onProjectButtonPressed(_:)), for: .touchUpInside)
        setupRootTabBarController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(onSceneNavigationStateDidChange(notification:)), name: .sceneNavigationStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onObjectInpectionStateDidChange(notification:)), name: .objectInpectionStateDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupRootTabBarController() {
        rootTabBarController = self.storyboard!.instantiateViewController(identifier: RootViewController.rootTabBarControllerName)
        
        installViewController(rootTabBarController) { rootTabBarView in
            rootTabBarView.frame = view.bounds
            rootTabBarView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(rootTabBarView, belowSubview: projectBar)
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        isStatusBarHidden
    }
    
    var isFullScreenEnabled = false {
        didSet {
            if isFullScreenEnabled {
                self.projectBar.alpha = 0.0
                self.rootTabBarController.tabBar.alpha = 0.0
            } else {
                self.projectBar.alpha = 1.0
                self.rootTabBarController.tabBar.alpha = 1.0
            }
        }
    }
    
    var isStatusBarHidden = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    @objc func onObjectInpectionStateDidChange(notification: Notification) {
        let isInspecting = notification.userInfo!["value"] as! Bool
        UIView.animate(withDuration: 0.3) {
            self.isFullScreenEnabled = isInspecting
        }
    }
    
    @objc func onSceneNavigationStateDidChange(notification: Notification) {
        let isNavigating = notification.userInfo!["value"] as! Bool
        UIView.animate(withDuration: 0.3) {
            self.isFullScreenEnabled = isNavigating
            self.isStatusBarHidden = isNavigating
        }
    }
    
    // MARK: Project handling
    @objc func onProjectButtonPressed(_ button: UIButton) {
        let projectBrowserVC = UIHostingController(rootView: ProjectBrowser(model: ProjectBrowserModel(), onRemoveAction: { _ in
            // TODO
        }, onDoneAction: { project in
            // TODO
            self.dismiss(animated: true)
        }))
        present(projectBrowserVC, animated: true)
    }
    
    static let rootTabBarControllerName = "RootTabBarController"
}
