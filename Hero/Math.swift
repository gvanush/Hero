//
//  Math.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/25/20.
//

import Foundation

func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

func deg2rad<T>(_ deg: T) -> T where T : FloatingPoint {
    deg * T.pi / T(180)
}

func rad2deg<T>(_ rad: T) -> T where T : FloatingPoint {
    rad * T(180) / T.pi
}

func clamp<T>(_ value: T, min minVal: T, max maxVal: T) -> T where T : Comparable {
    max(minVal, min(value, maxVal))
}
