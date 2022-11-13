//
//  AnimatablePropertyUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.11.22.
//

import Foundation


extension SPTAnimatableObjectProperty: Displayable {
    
    var displayName: String {
        switch self {
        case .positionX:
            return "X"
        case .positionY:
            return "Y"
        case .positionZ:
            return "Z"
        case .hue:
            return "Hue"
        case .saturation:
            return "Saturation"
        case .brightness:
            return "Brightness"
        case .red:
            return "Red"
        case .green:
            return "Green"
        case .blue:
            return "Blue"
        case .shininess:
            return "Shininess"
        }
    }
    
}
