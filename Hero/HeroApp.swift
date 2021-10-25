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
        RenderingContext.setup()
    }
    
    var body: some SwiftUI.Scene {
        WindowGroup {
            TransformView()
        }
    }
}
