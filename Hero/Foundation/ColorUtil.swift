//
//  Color+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

extension Color {
    
    init(sptHSBA hsba: SPTHSBAColor) {
        self.init(hue: Double(hsba.hue), saturation: Double(hsba.saturation), brightness: Double(hsba.brightness), opacity: Double(hsba.alpha))
    }
    
    init(sptRGBA rgba: SPTRGBAColor) {
        self.init(red: Double(rgba.red), green: Double(rgba.green), blue: Double(rgba.blue), opacity: Double(rgba.alpha))
    }
    
    static let defaultShadowColor = Color("DefaultShadowColor")
    static let primarySelectionColor = Color(uiColor: .primarySelectionColor)
    static let primaryLightSelectionColor = Color(uiColor: .primaryLightSelectionColor)
    
    static let xAxis = Color(uiColor: .xAxis)
    static let xAxisLight = Color(uiColor: .xAxisLight)
    static let xAxisDark = Color(uiColor: .xAxisDark)
    
    static let yAxis = Color(uiColor: .yAxis)
    static let yAxisLight = Color(uiColor: .yAxisLight)
    static let yAxisDark = Color(uiColor: .yAxisDark)
    
    static let zAxis = Color(uiColor: .zAxis)
    static let zAxisLight = Color(uiColor: .zAxisLight)
    static let zAxisDark = Color(uiColor: .zAxisDark)
    
    static let guide1 = Color(uiColor: .guide1)
    static let guide1Light = Color(uiColor: .guide1Light)
    static let guide1Dark = Color(uiColor: .guide1Dark)
    
    static let guide2 = Color(uiColor: .guide2)
    static let guide2Light = Color(uiColor: .guide2Light)
    static let guide2Dark = Color(uiColor: .guide2Dark)
    
    static let guide3 = Color(uiColor: .guide3)
    static let guide3Light = Color(uiColor: .guide3Light)
    static let guide3Dark = Color(uiColor: .guide3Dark)
    
    static let label = Color(uiColor: .label)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
    static let tertiaryLabel = Color(uiColor: .tertiaryLabel)
    static let quaternaryLabel = Color(uiColor: .quaternaryLabel)
    
    static let systemFill = Color(uiColor: .systemFill)
    static let secondarySystemFill = Color(uiColor: .secondarySystemFill)
    static let tertiarySystemFill = Color(uiColor: .tertiarySystemFill)
    static let quaternarySystemFill = Color(uiColor: .quaternarySystemFill)
    
    static let systemBackground = Color(uiColor: .systemBackground)
    static let secondarySystemBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiarySystemBackground = Color(uiColor: .tertiarySystemBackground)
    
    static let disabledControl = Color(hue: 240.0 / 360.0, saturation: 10.0 / 100.0, brightness: 26.0 / 100.0, opacity: 30.0 / 100.0)
 
    static let controlValue = Color("ControlValueColor")
    
    static let ultraLightAccentColor = Color.accentColor.opacity(0.3)
    
    static let lightAccentColor = Color.accentColor.opacity(0.65)
    
    static let darkGray = Color(uiColor: .darkGray)
    static let lightGray = Color(uiColor: .lightGray)
}


enum RGBColorChannel: Int, ElementProperty {
    case red
    case green
    case blue
}


enum HSBColorChannel: Int, ElementProperty {
    case hue
    case saturation
    case brightness
}
