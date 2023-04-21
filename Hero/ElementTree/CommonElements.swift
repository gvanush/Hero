//
//  CommonElements.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct CompositeElement<C>: Element
where C: Element {
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var content: C
    
    @Namespace var namespace
    
    init(title: String, @ElementBuilder content: () -> C) {
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
