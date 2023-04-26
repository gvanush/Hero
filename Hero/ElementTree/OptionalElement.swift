//
//  ConditionalElements.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct OptionalElement<E>: Element
where E: Element {
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var element: E?
    
    @Namespace var namespace
    
    init(element: E?) {
        self.element = element
    }
    
    var sizeAsContent: Int {
        element?.sizeAsContent ?? 0
    }
    
    var body: some View {
        if let element = element {
            element
                .indexPath(indexPath)
                .activeIndexPath(_activeIndexPath.projectedValue)
        }
    }
    
    var title: String {
        fatalError()
    }
    
    var content: some Element {
        fatalError()
    }
    
    var faceView: Never {
        fatalError()
    }
    
    var propertyView: Never {
        fatalError()
    }
    
}
