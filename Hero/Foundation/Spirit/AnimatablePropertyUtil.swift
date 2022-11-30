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
        case .cartesianPositionX:
            return "X"
        case .cartesianPositionY:
            return "Y"
        case .cartesianPositionZ:
            return "Z"
        case .linearPositionOffset:
            return "Offset"
        case .sphericalPositionRadius:
            return "Radius"
        case .sphericalPositionLongitude:
            return "Longitude"
        case .sphericalPositionLatitude:
            return "Latitude"
        case .cylindricalPositionRadius:
            return "Radius"
        case .cylindricalPositionLongitude:
            return "Longitude"
        case .cylindricalPositionHeight:
            return "Height"
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
