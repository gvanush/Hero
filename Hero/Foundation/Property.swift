//
//  Property.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.01.22.
//

import Foundation


protocol Property: CaseIterable, Identifiable, Equatable {
    var title: String { get }
}


enum Axis: Int, Property {
    
    case x
    case y
    case z
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .x:
            return "X"
        case .y:
            return "Y"
        case .z:
            return "Z"
        }
    }
    
}


enum VoidProperty: Property {
    
    var id: Int { 0 }
    
    var title: String {
        ""
    }
    
}
