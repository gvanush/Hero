//
//  Comparable+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 3/5/21.
//

extension Comparable {
    
    func clamped(min minVal: Self, max maxVal: Self) -> Self {
        max(self, min(self, maxVal))
    }
    
}
