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
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
            
            let toolbarAppearance = UIToolbarAppearance()
            toolbarAppearance.configureWithDefaultBackground()
            UIToolbar.appearance().standardAppearance = toolbarAppearance
            UIToolbar.appearance().compactAppearance = toolbarAppearance
            UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
            UIToolbar.appearance().compactScrollEdgeAppearance = toolbarAppearance
        }
        
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            RootView()
//            IntField_Previews.previews
        }
    }
}
