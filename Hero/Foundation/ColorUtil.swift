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
    
    static let tertiary = Color(uiColor: .tertiaryLabel)
    static let quaternary = Color(uiColor: .quaternaryLabel)
    
    static let systemFill = Color(uiColor: .systemFill)
    static let secondarySystemFill = Color(uiColor: .secondarySystemFill)
    static let tertiarySystemFill = Color(uiColor: .tertiarySystemFill)
    static let quaternarySystemFill = Color(uiColor: .quaternarySystemFill)
    
    static let disabledControl = Color(hue: 240.0 / 360.0, saturation: 10.0 / 100.0, brightness: 26.0 / 100.0, opacity: 30.0 / 100.0)
    
}
