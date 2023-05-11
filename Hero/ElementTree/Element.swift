//
//  Element.swift
//  Hero
//
//  Created by Vanush Grigoryan on 18.04.23.
//

import SwiftUI

struct ElementData: Equatable {
    let id: AnyHashable
    let title: String
    var subtitle: String?
    let indexPath: IndexPath
    let namespace: Namespace.ID
}

struct DisclosedElementsPreferenceKey: PreferenceKey {
    static var defaultValue = [ElementData]()

    static func reduce(value: inout [ElementData], nextValue: () -> [ElementData]) {
        value.append(contentsOf: nextValue())
    }
}

typealias ElementProperty = Hashable & CaseIterable & Displayable

enum ElementEmptyProperty: ElementProperty {
    case none
    
    static var allCases = [ElementEmptyProperty]()
}

protocol Element: View, Identifiable {
    
    var title: String { get }
    
    var subtitle: String? { get }
    
    var isReady: Bool { get }
    
    var indexPath: IndexPath! { get set }
    var _activeIndexPath: Binding<IndexPath>! { get set }
    
    associatedtype Content: Element = EmptyElement
    
    @ElementBuilder var content: Content { get }
    
    var sizeAsContent: Int { get }
    
    associatedtype Property: ElementProperty = ElementEmptyProperty
    var activeProperty: Property { get nonmutating set }
    
    associatedtype ActionView: View = EmptyView
    @ViewBuilder var actionView: ActionView { get }
    
    associatedtype OptionsView: View = EmptyView
    @ViewBuilder var optionsView: OptionsView { get }
    
    var namespace: Namespace.ID { get }
    
    func onAwake()
    
    func onSleep()
    
    func onParentDisclosed()
    
    func onParentClosed()
    
    func onDisclose()
    
    func onClose()
    
    func onActive()
    
    func onInactive()
    
    func onActivePropertyChange()
    
    func onPrepare()
        
}


extension Element {
    
    var isReady: Bool {
        true
    }
    
    var subtitle: String? {
        nil
    }
    
    var activeIndexPath: IndexPath {
        get {
            _activeIndexPath.wrappedValue
        }
        nonmutating set {
            _activeIndexPath.wrappedValue = newValue
        }
    }
    
    var isActive: Bool {
        isReady && indexPath == activeIndexPath
    }
    
    var isChildOfActive: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeIndexPath
    }
    
    var isDisclosed: Bool {
        isReady && activeIndexPath.starts(with: indexPath)
    }
    
    var isParentDisclosed: Bool {
        isReady && (indexPath.isEmpty || activeIndexPath.starts(with: indexPath.dropLast()))
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
    
    func onParentDisclosed() {
        
    }
    
    func onParentClosed() {
        
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
    
    func onPrepare() {
        
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
