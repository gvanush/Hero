//
//  Color+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.21.
//

import SwiftUI

extension Color {
    
    static let defaultShadowColor = Color("DefaultShadowColor")
    static let objectSelectionColor = Color(uiColor: .objectSelectionColor)
    
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
