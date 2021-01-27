//
//  Float+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/27/21.
//

import Foundation

func easeInOut<T>(normValue: T) -> T where T : FloatingPoint {
    normValue * normValue * (T(3) - T(2) * normValue)
}
