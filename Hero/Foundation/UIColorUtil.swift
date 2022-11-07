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
    
    var hsba: simd_float4 {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return simd_float4(x: Float(hue), y: Float(saturation), z: Float(brightness), w: Float(alpha))
    }
    
    func sptColor(model: SPTColorModel) -> SPTColor {
        switch model {
        case .RGB:
            return .init(rgba: .init(float4: self.rgba))
        case .HSB:
            return .init(hsba: .init(float4: self.hsba))
        }
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
    
    static let primarySelectionColor = UIColor.orange
    static let primaryLightSelectionColor = UIColor.yellow
    static let secondarySelectionColor = UIColor(named: "secondarySelectionColor")!
    static let secondaryLightSelectionColor = UIColor(named: "secondaryLightSelectionColor")!
    
    static let xAxis = UIColor(named: "XAxisColor")!
    static let xAxisLight = UIColor(named: "XAxisLightColor")!
    
    static let yAxis = UIColor(named: "YAxisColor")!
    static let yAxisLight = UIColor(named: "YAxisLightColor")!
    
    static let zAxis = UIColor(named: "ZAxisColor")!
    static let zAxisLight = UIColor(named: "ZAxisLightColor")!
}
