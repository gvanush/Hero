//
//  SIMD+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/6/20.
//

import simd


extension SIMD2 where Scalar == Float {
    init(from point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
}

extension SIMD3 where Scalar == Float {
    static let left = Self(-1.0, 0.0, 0.0)
    static let right = Self(1.0, 0.0, 0.0)
    static let down = Self(0.0, -1.0, 0.0)
    static let up = Self(0.0, 1.0, 0.0)
    static let backward = Self(0.0, 0.0, -1.0)
    static let forward = Self(0.0, 0.0, 1.0)
}

extension SIMD4 where Scalar == Float {
    static let red = Self(1.0, 0.0, 0.0, 1.0)
    static let green = Self(0.0, 1.0, 0.0, 1.0)
    static let blue = Self(0.0, 0.0, 1.0, 1.0)
}
