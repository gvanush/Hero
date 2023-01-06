//
//  OrientationUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.01.23.
//

import Foundation


extension SPTOrientationModel: CaseIterable, Identifiable, Displayable {
    
    public var id: UInt32 {
        self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .eulerXYZ:
            return "Euler XYZ"
        case .eulerXZY:
            return "Euler XZY"
        case .eulerYXZ:
            return "Euler YXZ"
        case .eulerYZX:
            return "Euler YZX"
        case .eulerZXY:
            return "Euler ZXY"
        case .eulerZYX:
            return "Euler ZYX"
        case .lookAtPoint:
            fatalError()
        case .lookAtDirection:
            fatalError()
        case .xyAxis:
            fatalError()
        case .yzAxis:
            fatalError()
        case .zxAxis:
            fatalError()
        }
    }
    
    public static var allCases: [SPTOrientationModel] = [.eulerXYZ, .eulerXZY, .eulerYXZ, .eulerYZX, .eulerZXY, .eulerZYX]
    
}


extension simd_float3 {
    
    var xInDegrees: Float {
        get {
            toDegrees(radians: x)
        }
        set {
            x = toRadians(degrees: newValue)
        }
    }
    
    var yInDegrees: Float {
        get {
            toDegrees(radians: y)
        }
        set {
            y = toRadians(degrees: newValue)
        }
    }
    
    var zInDegrees: Float {
        get {
            toDegrees(radians: z)
        }
        set {
            z = toRadians(degrees: newValue)
        }
    }
    
}
