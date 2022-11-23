//
//  SPTCoordinateSystemUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.11.22.
//

import Foundation

extension SPTLinearCoordinates: Equatable {
    
    init(origin: simd_float3, cartesian: simd_float3) {
        self = SPTLinearCoordinatesCreate(origin, cartesian)
    }
    
    var toCartesian: simd_float3 {
        SPTLinearCoordinatesToCartesian(self)
    }
    
    public static func == (lhs: SPTLinearCoordinates, rhs: SPTLinearCoordinates) -> Bool {
        SPTLinearCoordinatesEqual(lhs, rhs)
    }
    
}

extension SPTSphericalCoordinates: Equatable {
    
    init(origin: simd_float3, cartesian: simd_float3) {
        self = SPTSphericalCoordinatesCreate(origin, cartesian)
    }
    
    var toCartesian: simd_float3 {
        SPTSphericalCoordinatesToCartesian(self)
    }
    
    public static func == (lhs: SPTSphericalCoordinates, rhs: SPTSphericalCoordinates) -> Bool {
        SPTSphericalCoordinatesEqual(lhs, rhs)
    }
    
}

extension SPTCylindricalCoordinates: Equatable {
    
    init(origin: simd_float3, cartesian: simd_float3) {
        self = SPTCylindricalCoordinatesCreate(origin, cartesian)
    }
    
    var toCartesian: simd_float3 {
        SPTCylindricalCoordinatesToCartesian(self)
    }
    
    public static func == (lhs: SPTCylindricalCoordinates, rhs: SPTCylindricalCoordinates) -> Bool {
        SPTCylindricalCoordinatesEqual(lhs, rhs)
    }
    
}

extension SPTCoordinateSystem: CaseIterable, Identifiable, Displayable {
    
    public var id: UInt32 {
        self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .cartesian:
            return "Cartesian"
        case .linear:
            return "Linear"
        case .spherical:
            return "Spherical"
        case .cylindrical:
            return "Cylindrical"
        }
    }
    
    public static var allCases: [SPTCoordinateSystem] = [.cartesian, .linear, .spherical, .cylindrical]
    
}
