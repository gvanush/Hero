//
//  CompBuilder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import Foundation


@resultBuilder enum CompBuilder {
    
    static func buildBlock(_ comps: [Comp]...) -> [Comp] {
        var result = [Comp]()
        for i in 0..<comps.count {
            for comp in comps[i] {
                result.append(comp.declarationID(i))
            }
        }
        return result
    }
    
    static func buildExpression(_ expression: Comp) -> [Comp] {
        [expression]
    }
    
    static func buildExpression(_ expression: Void) -> [Comp] {
        []
    }
    
    static func buildOptional(_ components: [Comp]?) -> [Comp] {
        components ?? []
    }
    
    static func buildEither(first components: [Comp]) -> [Comp] {
        components.map { $0.variationID(1) }
    }
    
    static func buildEither(second components: [Comp]) -> [Comp] {
        components.map { $0.variationID(2) }
    }
    
}
