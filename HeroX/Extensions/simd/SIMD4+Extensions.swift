//
//  SIMD4+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 3/5/21.
//

import simd

extension SIMD4 where Scalar == Float {
    static let red = Self(1.0, 0.0, 0.0, 1.0)
    static let green = Self(0.0, 1.0, 0.0, 1.0)
    static let blue = Self(0.0, 0.0, 1.0, 1.0)
}
