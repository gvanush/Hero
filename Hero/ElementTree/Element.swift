//
//  Element.swift
//  Hero
//
//  Created by Vanush Grigoryan on 18.04.23.
//

import SwiftUI


typealias ElementProperty = Hashable & CaseIterable & Displayable

enum ElementEmptyProperty: ElementProperty {
    case none
    
    static var allCases = [ElementEmptyProperty]()
}

protocol Element: View {
    
    var indexPath: IndexPath! { get set }
    var _activeIndexPath: Binding<IndexPath>! { get set }
    
    associatedtype Content: Element = EmptyElement
    
    @ElementBuilder var content: Content { get }
    
    var sizeAsContent: Int { get }
    
    associatedtype Property: ElementProperty = ElementEmptyProperty
    var activeProperty: Property { get nonmutating set }
    
    associatedtype ActionView: View = EmptyView
    @ViewBuilder var actionView: ActionView { get }
    
    associatedtype FaceView: View
    @ViewBuilder var faceView: FaceView { get }
    
    var namespace: Namespace.ID { get }
    
    func onAwake()
    
    func onSleep()
    
    func onDisclose()
    
    func onClose()
    
    func onActive()
    
    func onInactive()
    
    func onActivePropertyChange()
        
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
    
    func onAwake() {
        
    }
    
    func onSleep() {
        
    }
    
    func onDisclose() {
        
    }
    
    func onClose() {
        
    }
    
    func onActive() {
        
    }
    
    func onInactive() {
        
    }
    
    func onActivePropertyChange() {
        
    }
}


extension Element where Property == ElementEmptyProperty {
    
    var activeProperty: Property {
        get {
            .none
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
