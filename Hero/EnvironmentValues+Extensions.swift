//
//  EnvironmentValues+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/26/20.
//

import SwiftUI

struct HeroSceneKey: EnvironmentKey {
    typealias Value = HeroScene
    
    static var defaultValue = HeroScene()
}

extension EnvironmentValues {
    var scene: HeroScene {
        get { self[HeroSceneKey.self] }
        set { self[HeroSceneKey.self] = newValue }
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
