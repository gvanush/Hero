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


extension SPTSphericalCoordinates {
    
    var longitudeInDegrees: Float {
        get {
            toDegrees(radians: longitude)
        }
        set {
            longitude = toRadians(degrees: newValue)
        }
    }
    
    var latitudeInDegrees: Float {
        get {
            toDegrees(radians: latitude)
        }
        set {
            latitude = toRadians(degrees: newValue)
        }
    }
}
