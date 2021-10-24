//
//  FloatingPoint+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 3/5/21.
//

import Foundation

extension FloatingPoint {
    
    var easedInOut: Self {
        self * self * (Self(3) - Self(2) * self)
    }
    
}

func toRadian<T>(degree: T) -> T where T : FloatingPoint {
    degree * T.pi / T(180)
}

func toDegree<T>(radian: T) -> T where T : FloatingPoint {
    radian * T(180) / T.pi
}
