//
//  ComparableUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.02.22.
//

import Foundation


extension Comparable {
    
    func clamped(min minVal: Self, max maxVal: Self) -> Self {
        max(minVal, min(self, maxVal))
    }
    
}
