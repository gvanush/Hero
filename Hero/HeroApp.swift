//
//  HeroApp.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI

@main
struct HeroApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(world: World())
        }
    }
}
