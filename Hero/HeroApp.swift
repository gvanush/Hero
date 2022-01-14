//
//  HeroApp.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.10.21.
//

import SwiftUI

@main
struct HeroApp: App {
    
    init() {
        spt_init()
        
//        if #available(iOS 15.0, *) {
//            let navigationBarAppearance = UINavigationBarAppearance()
//            navigationBarAppearance.configureWithDefaultBackground()
//            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
//            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
//            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
//        }
        
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            RootView()
        }
    }
}
