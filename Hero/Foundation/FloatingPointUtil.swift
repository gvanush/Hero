//
//  FloatingPoint+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 3/5/21.
//

import Foundation

func toRadians<T>(degrees: T) -> T where T : FloatingPoint {
    degrees * T.pi / T(180)
}

func toDegrees<T>(radians: T) -> T where T : FloatingPoint {
    radians * T(180) / T.pi
}


extension Float {
 
    static let guidePointSmallSize: Float = 5.0
    static let guidePointRegularSize: Float = 6.0
    static let guidePointLargeSize: Float = 7.0
    
    static let guideLineThinThickness: Float = 2.0
    static let guideLineRegularThickness: Float = 3.0
    static let guideLineBoldThickness: Float = 5.0
 
}
