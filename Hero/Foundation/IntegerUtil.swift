//
//  IntegerUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.10.22.
//

import Foundation


extension FixedWidthInteger {
    
    static func randomInFullRange() -> Self {
        random(in: Self.min...Self.max)
    }

    
}
