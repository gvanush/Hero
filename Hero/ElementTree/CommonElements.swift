//
//  CommonElements.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct CompositeElement<C1, C2, C3, C4, C5>: Element
where C1: Element, C2: Element, C3: Element, C4: Element, C5: Element {
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var content: TupleElement<(C1, C2, C3, C4, C5)>
    
    @Namespace var namespace
    
    init(title: String, @ElementBuilder content: () -> TupleElement<(C1, C2, C3, C4, C5)>) {
        self.title = title
        self.content = content()
    }
    
}

struct LeafElement<P>: Element where P: ElementProperty {
    
    typealias Property = P
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @State var activeProperty: P
    
    @Namespace var namespace
    
    init(title: String, activeProperty: P) {
        self.title = title
        _activeProperty = .init(wrappedValue: activeProperty)
    }
    
}
