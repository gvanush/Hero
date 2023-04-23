//
//  CompositeElement.swift
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
