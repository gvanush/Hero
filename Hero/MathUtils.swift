//
//  MathUtils.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/25/20.
//

import Foundation

func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}
