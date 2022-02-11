//
//  SIMDUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.02.22.
//

import Foundation

extension SIMD3 where Scalar == Float {
    static let left = Self(-1.0, 0.0, 0.0)
    static let right = Self(1.0, 0.0, 0.0)
    static let down = Self(0.0, -1.0, 0.0)
    static let up = Self(0.0, 1.0, 0.0)
    static let backward = Self(0.0, 0.0, -1.0)
    static let forward = Self(0.0, 0.0, 1.0)
}

