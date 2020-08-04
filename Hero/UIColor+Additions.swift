//
//  UIColor+Additions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/3/20.
//

import UIKit
import simd

extension UIColor {
    var rgba: simd_float4 {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return simd_float4(x: Float(red), y: Float(green), z: Float(blue), w: Float(alpha))
    }
}
