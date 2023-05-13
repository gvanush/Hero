//
//  ConditionalElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


struct ConditionalElement<TE, FE>: Element
where TE: Element, FE: Element {
    
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    var trueElement: TE?
    var falseElement: FE?
    
    @Namespace var namespace
    
    init(trueElement: TE) {
        self.trueElement = trueElement
    }
    
    init(falseElement: FE) {
        self.falseElement = falseElement
    }
    
    var sizeAsContent: Int {
        (trueElement?.sizeAsContent ?? 0) + (falseElement?.sizeAsContent ?? 0)
    }
    
    var body: some View {
        trueElement?
            .indexPath(indexPath)
            .activeIndexPath(_activeIndexPath.projectedValue)
        
        falseElement?
            .indexPath(indexPath)
            .activeIndexPath(_activeIndexPath.projectedValue)
    }
    
    var id: Never {
        fatalError()
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
