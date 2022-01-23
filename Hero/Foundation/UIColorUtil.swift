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
    
    var mtlClearColor: MTLClearColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return MTLClearColor(red: Double(red), green: Double(green), blue: Double(blue), alpha: Double(alpha))
    }
    
    static var sceneBgrColor: UIColor {
        Self.systemGray2
    }
    
    static func random(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: alpha)
    }
    
    static let objectSelectionColor = UIColor.orange
}
