//
//  DistinctValueSet.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import Foundation


protocol DistinctValueSet: Identifiable, Equatable, CaseIterable {
    
}

extension DistinctValueSet {
    
    public var id: Self { self }
    
}

