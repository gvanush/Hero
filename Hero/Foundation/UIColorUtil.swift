//
//  UIColor+Additions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 8/3/20.
//

import UIKit
import simd

extension UIColor {
    
    convenience init(rgba: simd_float4) {
        self.init(red: CGFloat(rgba.x), green: CGFloat(rgba.y), blue: CGFloat(rgba.z), alpha: CGFloat(rgba.w))
    }
    
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
    
    static let sceneBgrColor = UIColor.systemGray2
    
    static let coordinateGridColor = UIColor.systemGray
    
    static func random(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: alpha)
    }
    
    static let primarySelectionColor = UIColor.orange
    static let primaryLightSelectionColor = UIColor.yellow
    
    static let xAxis = UIColor(named: "xAxisColor")!
    static let xAxisLight = UIColor(named: "xAxisLightColor")!
    static let xAxisDark = UIColor(named: "xAxisDarkColor")!
    
    static let yAxis = UIColor(named: "yAxisColor")!
    static let yAxisLight = UIColor(named: "yAxisLightColor")!
    static let yAxisDark = UIColor(named: "yAxisDarkColor")!
    
    static let zAxis = UIColor(named: "zAxisColor")!
    static let zAxisLight = UIColor(named: "zAxisLightColor")!
    static let zAxisDark = UIColor(named: "zAxisDarkColor")!
    
    static let guide1 = UIColor(named: "guide1Color")!
    static let guide1Light = UIColor(named: "guide1LightColor")!
    static let guide1Dark = UIColor(named: "guide1DarkColor")!
    
    static let guide2 = UIColor(named: "guide2Color")!
    static let guide2Light = UIColor(named: "guide2LightColor")!
    static let guide2Dark = UIColor(named: "guide2DarkColor")!
    
    static let guide3 = UIColor(named: "guide3Color")!
    static let guide3Light = UIColor(named: "guide3LightColor")!
    static let guide3Dark = UIColor(named: "guide3DarkColor")!
}
