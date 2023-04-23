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
    
    associatedtype Content: Element = EmptyElement
    
    @ElementBuilder var content: Content { get }
    
    var sizeAsContent: Int { get }
    
    associatedtype Property: ElementProperty = Never
    var activeProperty: Property { get nonmutating set }
    
    associatedtype ActionView: View = EmptyView
    @ViewBuilder var actionView: ActionView { get }
    
    var namespace: Namespace.ID { get }
        
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
    
    var sizeAsContent: Int {
        1
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

extension Element where Content == EmptyElement {
    
    var content: Content {
        .init()
    }
    
}

extension Element where ActionView == EmptyView {
    
    var actionView: ActionView {
        .init()
    }
    
}
