//
//  EnvironmentValues+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/26/20.
//

import SwiftUI

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
