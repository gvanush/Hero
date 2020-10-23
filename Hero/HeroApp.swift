//
//  HeroApp.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // MARK: This is a workaround to be able to change SwiftUI action sheet button colors
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor.systemIndigo
        
        try! ProjectDAO.shared.setup()
        
        Hero.Scene.setup()
        
        return true
    }
}

@main
struct HeroApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            RootView()
                .environment(\.scene, Hero.Scene())
                .environment(\.gpu, RenderingContext.device())
            
        }
    }
}
