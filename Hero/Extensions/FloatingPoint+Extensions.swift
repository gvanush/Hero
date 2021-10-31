//
//  FloatingPoint+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 3/5/21.
//

import Foundation

func toRadians<T>(degrees: T) -> T where T : FloatingPoint {
    degrees * T.pi / T(180)
}

func toDegrees<T>(radians: T) -> T where T : FloatingPoint {
    radians * T(180) / T.pi
}
