//
//  EnvironmentValues+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/26/20.
//

import SwiftUI

struct SceneKey: EnvironmentKey {
    typealias Value = Hero.Scene
    
    static var defaultValue = Scene()
}

extension EnvironmentValues {
    var scene: Hero.Scene {
        get { self[SceneKey.self] }
        set { self[SceneKey.self] = newValue }
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
