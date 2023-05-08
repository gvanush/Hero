//
//  TupleElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 21.04.23.
//

import SwiftUI


struct TupleElement<E1, E2, E3, E4, E5>: Element
where E1: Element, E2: Element, E3: Element, E4: Element, E5: Element {

    var elements: (E1, E2, E3, E4, E5)

    init(_ value: (E1, E2, E3, E4, E5)) {
        self.elements = value
    }

    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var id: Never {
        fatalError()
    }
    
    var title: String {
        fatalError()
    }
    
    var namespace: Namespace.ID {
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
    
    var sizeAsContent: Int {
        elements.0.sizeAsContent + elements.1.sizeAsContent + elements.2.sizeAsContent + elements.3.sizeAsContent + elements.4.sizeAsContent
    }
    
    var body: some View {
        Group {
            elements.0
                .indexPath(indexPath)
                .activeIndexPath(_activeIndexPath.projectedValue)

            elements.1
                .indexPath(indexPath.bumpingLast(elements.0.sizeAsContent))
                .activeIndexPath(_activeIndexPath.projectedValue)

            elements.2
                .indexPath(indexPath.bumpingLast(elements.0.sizeAsContent + elements.1.sizeAsContent))
                .activeIndexPath(_activeIndexPath.projectedValue)

            elements.3
                .indexPath(indexPath.bumpingLast(elements.0.sizeAsContent + elements.1.sizeAsContent + elements.2.sizeAsContent))
                .activeIndexPath(_activeIndexPath.projectedValue)

            elements.4
                .indexPath(indexPath.bumpingLast(elements.0.sizeAsContent + elements.1.sizeAsContent + elements.2.sizeAsContent + elements.3.sizeAsContent))
                .activeIndexPath(_activeIndexPath.projectedValue)
        }
    }
    
}
