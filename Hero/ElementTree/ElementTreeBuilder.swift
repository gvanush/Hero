//
//  ElementTreeBuilder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI


@resultBuilder struct ElementBuilder {

    static func buildBlock() -> (EmptyElement, EmptyElement, EmptyElement, EmptyElement, EmptyElement) {
        (.init(), .init(), .init(), .init(), .init())
    }

    static func buildBlock<E>(_ element: E) -> (E, EmptyElement, EmptyElement, EmptyElement, EmptyElement)
    where E: Element {
        (element, .init(), .init(), .init(), .init())
    }

    static func buildBlock<E1, E2>(_ element1: E1, _ element2: E2) -> (E1, E2, EmptyElement, EmptyElement, EmptyElement)
    where E1: Element, E2: Element {
        (element1, element2, .init(), .init(), .init())
    }
    
    static func buildBlock<E1, E2, E3>(_ element1: E1, _ element2: E2,  _ element3: E3) -> (E1, E2, E3, EmptyElement, EmptyElement)
    where E1: Element, E2: Element, E3: Element {
        (element1, element2, element3, .init(), .init())
    }
    
    static func buildBlock<E1, E2, E3, E4>(_ element1: E1, _ element2: E2,  _ element3: E3, _ element4: E4) -> (E1, E2, E3, E4, EmptyElement)
    where E1: Element, E2: Element, E3: Element, E4: Element {
        (element1, element2, element3, element4, .init())
    }
    
    static func buildBlock<E1, E2, E3, E4, E5>(_ element1: E1, _ element2: E2,  _ element3: E3, _ element4: E4, element5: E5) -> (E1, E2, E3, E4, E5)
    where E1: Element, E2: Element, E3: Element, E4: Element, E5: Element {
        (element1, element2, element3, element4, element5)
    }

    static func buildOptional<E1, E2, E3, E4, E5>(_ elements: (E1, E2, E3, E4, E5)?) -> OptionalElement<E1, E2, E3, E4, E5>
    where E1: Element, E2: Element, E3: Element, E4: Element, E5: Element {
        .init(elements: elements)
    }
    
}


