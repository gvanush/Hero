//
//  CompositeElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct CompositeElement<ID, C>: Element
where ID: Hashable, C: Element {
    
    let id: ID
    let title: String
    var subtitle: String?
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var content: C
    
    @Namespace var namespace
    
    init(id: ID, title: String, subtitle: String? = nil, @ElementBuilder content: () -> C) {
        self.title = title
        self.subtitle = subtitle
        self.id = id
        self.content = content()
    }
    
}
