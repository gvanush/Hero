//
//  HeroApp.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI

struct CanvasKey: EnvironmentKey {
    typealias Value = Canvas
    
    static var defaultValue = Canvas()
}

extension EnvironmentValues {
    var canvas: Canvas {
        get { self[CanvasKey.self] }
        set { self[CanvasKey.self] = newValue }
    }
}

struct GpuKey: EnvironmentKey {
    typealias Value = MTLDevice
    
    static var defaultValue = RenderingContext.device()
}

extension EnvironmentValues {
    var gpu: MTLDevice {
        get { self[GpuKey.self] }
        set { self[GpuKey.self] = newValue }
    }
}

@main
struct HeroApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.canvas, Canvas())
                .environment(\.gpu, RenderingContext.device())
            
        }
    }
}
