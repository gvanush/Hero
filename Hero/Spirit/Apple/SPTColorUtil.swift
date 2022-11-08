//
//  SPTColorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.11.22.
//

import Foundation


extension SPTColor: Equatable {
    
    init(rgba: SPTRGBAColor) {
        self.init(model: .RGB, .init(rgba: rgba))
    }
    
    init(hsba: SPTHSBAColor) {
        self.init(model: .HSB, .init(hsba: hsba))
    }
    
    var toRGBA: SPTColor {
        SPTColorToRGBA(self)
    }
    
    var toHSBA: SPTColor {
        SPTColorToHSBA(self)
    }
    
    public static func == (lhs: SPTColor, rhs: SPTColor) -> Bool {
        SPTColorEqual(lhs, rhs)
    }
    
}

extension SPTRGBAColor: Equatable {
    
    init(red: Float, green: Float, blue: Float, alpha: Float = 1.0) {
        self.init(.init(red: red, green: green, blue: blue, alpha: alpha))
    }
    
    var hsba: SPTHSBAColor {
        SPTRGBAColorToHSBA(self)
    }
    
    public static func == (lhs: SPTRGBAColor, rhs: SPTRGBAColor) -> Bool {
        SPTRGBAColorEqual(lhs, rhs)
    }
    
}

extension SPTHSBAColor: Equatable {
    
    init(hue: Float, saturation: Float, brightness: Float, alpha: Float = 1.0) {
        self.init(.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha))
    }
    
    public static func == (lhs: SPTHSBAColor, rhs: SPTHSBAColor) -> Bool {
        SPTHSBAColorEqual(lhs, rhs)
    }
    
    var rgba: SPTRGBAColor {
        SPTHSBAColorToRGBA(self)
    }
    
}

extension SPTColorModel: CaseIterable, Identifiable, Displayable {
    
    public var id: UInt32 {
        self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .RGB:
            return "RGB"
        case .HSB:
            return "HSB"
        }
    }
    
    public static var allCases: [SPTColorModel] = [.HSB, .RGB]
    
}
