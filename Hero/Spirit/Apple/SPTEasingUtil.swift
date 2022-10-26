//
//  SPTEasingUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.22.
//

import Foundation


extension SPTEasingType: Displayable {
    
    var displayName: String {
        switch self {
        case .linear:
            return "Linear"
        case .smoothStep:
            return "Smoothstep"
        case .smootherStep:
            return "Smootherstep"
        }
    }
    
}
