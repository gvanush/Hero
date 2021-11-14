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
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            TransformView()
        }
    }
}
