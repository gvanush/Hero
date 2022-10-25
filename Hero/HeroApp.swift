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
        SPTInit()
        
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
        
        _ = SPTAnimator.make(.init(name: "Pan.0", source: .init(panWithAxis: .horizontal, bottomLeft: .zero, topRight: .one)))
        _ = SPTAnimator.make(.init(name: "Random.0", source: .init(randomWithSeed: 1, frequency: 3.0)))
        _ = SPTAnimator.make(.init(name: "Noise.0", source: .init(noiseWithSeed: 1, frequency: 1.0)))
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            RootView()
        }
    }
}
