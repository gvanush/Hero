//
//  Component.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.02.22.
//

import Foundation
import SwiftUI


class Component: Identifiable, ObservableObject, Equatable {
    
    private(set) weak var parent: Component?
    @Published var isActive = false
    @Published var isDisclosed = false
    var variantTag: UInt32 = 0
    
    init(parent: Component?) {
        self.parent = parent
    }
    
    var id: ObjectIdentifier { ObjectIdentifier(self) }
    var title: String {
        fatalError("This property must be overriden by subcalsses")
    }
    var properties: [String]? { nil }
    var selectedPropertyIndex: Int? {
        set { }
        get { nil }
    }
    var subcomponents: [Component]? { nil }
    
    var isSetup: Bool { true }
    
    func onActive() { }
    
    func onInactive() { }
    
    func onDisclose() { }
    
    func onClose() { }
    
    func onVisible() {}
    
    func onInvisible() {}
    
    func activate() {
        isActive = true
        onActive()
    }
    
    func deactivate() {
        isActive = false
        onInactive()
    }
    
    func disclose() {
        isDisclosed = true
        onDisclose()
        if let subcomponents = subcomponents {
            for subcomponent in subcomponents {
                subcomponent.appear()
            }
        }
    }
    
    func close() {
        isDisclosed = false
        if let subcomponents = subcomponents {
            for subcomponent in subcomponents {
                subcomponent.disappear()
            }
        }
        onClose()
    }
    
    func appear() {
        onVisible()
    }
    
    func disappear() {
        onInvisible()
    }
    
    func indexPathIn(_ root: Component) -> IndexPath? {
        
        if self == root {
            return IndexPath()
        }
        
        guard let parent = parent else {
            return nil
        }
        
        guard var indexPath = parent.indexPathIn(root) else {
            return nil
        }
        
        guard let index = parent.subcomponents!.firstIndex(of: self) else {
            fatalError("Component is not in its own parent's subcomponents")
        }
        indexPath.append(index)
        
        return indexPath
    }
    
    func componentAt(_ indexPath: IndexPath) -> Component? {
        
        if indexPath.isEmpty {
            return self
        }
        
        guard let subcomponents = subcomponents, indexPath.first! < subcomponents.count else {
            return nil
        }
        
        return subcomponents[indexPath.first!].componentAt(indexPath.dropFirst())
        
    }
    
    func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        nil
    }
    
    func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        fatalError("This method must be overridden in sub components that can have 'isSetup' false")
    }
    
    static func == (lhs: Component, rhs: Component) -> Bool {
        lhs.id == rhs.id
    }
    
}

class BasicComponent<P>: Component where P: RawRepresentable & CaseIterable & Displayable, P.RawValue == Int {
    
    @Published var selectedProperty: P
    
    init(selectedProperty: P, parent: Component?) {
        self.selectedProperty = selectedProperty
        super.init(parent: parent)
    }
    
    override var properties: [String]? {
        P.allCaseDisplayNames
    }
    
    override var selectedPropertyIndex: Int? {
        set {
            selectedProperty = .init(rawValue: newValue)!
        }
        get {
            selectedProperty.rawValue
        }
    }
    
}


class MultiVariantComponent: Component {
    
    @Published var activeComponent: Component! {
        willSet {
            if isActive {
                activeComponent.deactivate()
            }
            
            if let parent = parent {
                if parent.isDisclosed {
                    newValue.appear()
                }
            } else {
                newValue.appear()
            }
            
            if isDisclosed {
                activeComponent.close()
                newValue.disclose()
            }
            
            if let parent = parent {
                if parent.isDisclosed {
                    activeComponent.disappear()
                }
            } else {
                activeComponent?.disappear()
            }
            
            if isActive {
                newValue.activate()
            }
        }
    }
    
    override func activate() {
        super.activate()
        activeComponent.activate()
    }
    
    override func deactivate() {
        activeComponent.deactivate()
        super.deactivate()
    }
    
    override func disclose() {
        isDisclosed = true
        onDisclose()
        activeComponent.disclose()
    }
    
    override func close() {
        activeComponent.close()
        onClose()
        isDisclosed = false
    }
        
    override func appear() {
        super.appear()
        activeComponent.appear()
    }

    override func disappear() {
        activeComponent.disappear()
        super.disappear()
    }
    
    override var id: ObjectIdentifier {
        activeComponent.id
    }
    
    override var title: String {
        activeComponent.title
    }
    
    override var properties: [String]? {
        activeComponent.properties
    }
    
    override var selectedPropertyIndex: Int? {
        get {
            activeComponent.selectedPropertyIndex
        }
        set {
            activeComponent.selectedPropertyIndex = newValue
        }
    }
    
    override var subcomponents: [Component]? {
        activeComponent.subcomponents
    }
    
    override func onActive() {
    }
    
    override func onInactive() {
    }
    
    override func onDisclose() {
    }
    
    override func onClose() {
    }
}
