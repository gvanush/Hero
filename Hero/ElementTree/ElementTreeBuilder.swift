//
//  ElementTreeBuilder.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.04.23.
//

import SwiftUI


@resultBuilder struct ElementBuilder {
    
    static func buildBlock() -> TupleElement<EmptyElement, EmptyElement, EmptyElement, EmptyElement, EmptyElement> {
        .init((.init(), .init(), .init(), .init(), .init()))
    }

    static func buildBlock<E>(_ element: E) -> TupleElement<E, EmptyElement, EmptyElement, EmptyElement, EmptyElement>
    where E: Element {
        .init((element, .init(), .init(), .init(), .init()))
    }

    static func buildBlock<E1, E2>(_ element1: E1, _ element2: E2) -> TupleElement<E1, E2, EmptyElement, EmptyElement, EmptyElement>
    where E1: Element, E2: Element {
        .init((element1, element2, .init(), .init(), .init()))
    }
    
    static func buildBlock<E1, E2, E3>(_ element1: E1, _ element2: E2,  _ element3: E3) -> TupleElement<E1, E2, E3, EmptyElement, EmptyElement>
    where E1: Element, E2: Element, E3: Element {
        .init((element1, element2, element3, .init(), .init()))
    }
    
    static func buildBlock<E1, E2, E3, E4>(_ element1: E1, _ element2: E2,  _ element3: E3, _ element4: E4) -> TupleElement<E1, E2, E3, E4, EmptyElement>
    where E1: Element, E2: Element, E3: Element, E4: Element {
        .init((element1, element2, element3, element4, .init()))
    }
    
    static func buildBlock<E1, E2, E3, E4, E5>(_ element1: E1, _ element2: E2,  _ element3: E3, _ element4: E4, _ element5: E5) -> TupleElement<E1, E2, E3, E4, E5>
    where E1: Element, E2: Element, E3: Element, E4: Element, E5: Element {
        .init((element1, element2, element3, element4, element5))
    }

    static func buildOptional<E>(_ element: E?) -> OptionalElement<E>
    where E: Element {
        .init(element: element)
    }
    
    static func buildEither<E>(first element: E) -> E
    where E: Element {
        element
    }
    
    static func buildEither<E>(second element: E) -> E
    where E: Element {
        element
    }
    
}


