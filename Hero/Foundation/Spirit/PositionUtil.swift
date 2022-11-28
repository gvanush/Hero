//
//  PositionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.11.22.
//

import Foundation


extension SPTCylindricalCoordinates {
    
    var longitudeInDegrees: Float {
        get {
            toDegrees(radians: longitude)
        }
        set {
            longitude = toRadians(degrees: newValue)
        }
    }
    
}
