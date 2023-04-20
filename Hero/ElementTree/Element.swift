//
//  Element.swift
//  Hero
//
//  Created by Vanush Grigoryan on 18.04.23.
//

import SwiftUI


typealias ElementProperty = Hashable & CaseIterable & Displayable

protocol Element: View {
    
    var title: String { get }
    
    var indexPath: IndexPath! { get set }
    var _activeIndexPath: Binding<IndexPath>! { get set }
    
    associatedtype C1: Element = EmptyElement
    associatedtype C2: Element = EmptyElement
    associatedtype C3: Element = EmptyElement
    associatedtype C4: Element = EmptyElement
    associatedtype C5: Element = EmptyElement
    
    var content: (C1, C2, C3, C4, C5) { get set }
    
    var nodeCount: Int { get }
    
    associatedtype Property: ElementProperty = Never
    var activeProperty: Property { get nonmutating set }
 
    associatedtype FaceView: View
    var faceView: FaceView { get }
    
    associatedtype PropertyView: View
    var propertyView: PropertyView { get }
    
    var namespace: Namespace.ID { get }
    
    func indexPath(_ indexPath: IndexPath) -> Self
    
    func activeIndexPath(_ indexPath: Binding<IndexPath>) -> Self
    
}

extension Element {
    
    var activeIndexPath: IndexPath {
        get {
            _activeIndexPath.wrappedValue
        }
        nonmutating set {
            _activeIndexPath.wrappedValue = newValue
        }
    }
    
    var isActive: Bool {
        indexPath == activeIndexPath
    }
    
    var isChildOfActive: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeIndexPath
    }
    
    var isDisclosed: Bool {
        activeIndexPath.starts(with: indexPath)
    }
    
    func indexPath(_ indexPath: IndexPath) -> Self {
        var copy = self
        copy.indexPath = indexPath
        return copy
    }
    
    func activeIndexPath(_ indexPath: Binding<IndexPath>) -> Self {
        var copy = self
        copy._activeIndexPath = indexPath
        return copy
    }
    
    var nodeCount: Int {
        1 + content.0.nodeCount + content.1.nodeCount + content.2.nodeCount + content.3.nodeCount + content.4.nodeCount
    }
    
}


extension Element where Property == Never {
    
    var activeProperty: Property {
        get {
            fatalError()
        }
        nonmutating set {
            
        }
    }
    
}

extension Element where C1 == EmptyElement, C2 == EmptyElement, C3 == EmptyElement, C4 == EmptyElement, C5 == EmptyElement {
    
    var content: (C1, C2, C3, C4, C5) {
        get {
            (.init(), .init(), .init(), .init(), .init())
        }
        set {
            
        }
    }
    
}



