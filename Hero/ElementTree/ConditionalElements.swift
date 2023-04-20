//
//  ConditionalElements.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct OptionalElement<C1, C2, C3, C4, C5>: Element
where C1: Element, C2: Element, C3: Element, C4: Element, C5: Element {
    
     
    var title: String {
        fatalError()
    }
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var content: (C1, C2, C3, C4, C5) {
        get {
            fatalError()
        }
        set {
            
        }
    }
    
    var elements: (C1, C2, C3, C4, C5)?
    
    @Namespace var namespace
    
    init(elements: (C1, C2, C3, C4, C5)?) {
        self.elements = elements
    }
    
    var nodeCount: Int {
        if let elements = elements {
            return elements.0.nodeCount + elements.1.nodeCount + elements.2.nodeCount + elements.3.nodeCount + elements.4.nodeCount
        }
        return 0
    }
    
    var body: some View {
        if let elements = elements {
            elementGroupView(elements, baseIndexPath: indexPath.dropLast(), offset: indexPath.last!)
                .transition(AnyTransition.opacity.animation(elementNavigationAnimation))
        }
    }
}
