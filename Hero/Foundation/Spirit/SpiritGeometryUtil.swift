//
//  GeometryUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.01.23.
//

import Foundation


extension SPTAxis: DistinctValueSet, Displayable {
    
    public static var allCases: [SPTAxis] {
        [.X, .Y, .Z]
    }

    var displayName: String {
        switch self {
        case .X:
            return "X"
        case .Y:
            return "Y"
        case .Z:
            return "Z"
        }
    }
}
