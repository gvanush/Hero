//
//  GeometryUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import Foundation
import SwiftUI


enum Axis: Int, DistinctValueSet, Displayable {
    case x
    case y
    case z
    
    init(_ sptValue: SPTAxis) {
        switch sptValue {
        case .X:
            self = .x
        case .Y:
            self = .y
        case .Z:
            self = .z
        }
    }
    
    var sptValue: SPTAxis {
        switch self {
        case .x:
            return .X
        case .y:
            return .Y
        case .z:
            return .Z
        }
    }
}


enum Plain: Int, DistinctValueSet, Displayable {
    case xy
    case yz
    case zx
    
    init(_ sptValue: SPTPlain) {
        switch sptValue {
        case .XY:
            self = .xy
        case .YZ:
            self = .yz
        case .ZX:
            self = .zx
        }
    }
    
    var sptValue: SPTPlain {
        switch self {
        case .xy:
            return .XY
        case .yz:
            return .YZ
        case .zx:
            return .ZX
        }
    }
    
}
