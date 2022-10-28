//
//  Component.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.02.22.
//

import Foundation
import SwiftUI

struct ComponentPath {
    
    struct Node {
        var index: Int
//        var variantId: Int
    }
    
    var nodes = [Node]()
    
}

class Component: Identifiable, ObservableObject, Equatable {
    
    let title: String
    private(set) weak var parent: Component?
    
    init(title: String, parent: Component?) {
        self.title = title
        self.parent = parent
    }
    
    var id: ObjectIdentifier { ObjectIdentifier(self) }
    var properties: [String]? { nil }
    var selectedPropertyIndex: Int? {
        set { }
        get { nil }
    }
    var subcomponents: [Component]? { nil }
    
    var isSetup: Bool { true }
    
    func onActive() { }
    
    func onInactive() { }
    
    @Published var actions = [ActionItem]()
    
    func pathIn(_ root: Component) -> ComponentPath? {
        
        if self == root {
            return ComponentPath()
        }
        
        guard let parent = parent else {
            return nil
        }
        
        guard var path = parent.pathIn(root) else {
            return nil
        }
        
        guard let index = parent.subcomponents!.firstIndex(of: self) else {
            fatalError("Component is not in its own parent's subcomponents")
        }
        path.nodes.append(.init(index: index))
        
        return path
    }
    
    func componentAt(_ path: ComponentPath) -> Component? {
        return componentAt(path, index: 0)
    }
    
    private func componentAt(_ path: ComponentPath, index: Int) -> Component? {
        
        guard index < path.nodes.count else {
            return self
        }
        
        let subIndex = path.nodes[index].index
        
        guard let subs = subcomponents, subIndex < subs.count else {
            return nil
        }
        
        return subs[subIndex].componentAt(path, index: index + 1)
        
    }
    
    func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        nil
    }
    
    func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        fatalError("This method must be overridden in sub components that can have 'isSetup' false")
    }
    
    static func == (lhs: Component, rhs: Component) -> Bool {
        lhs === rhs
    }
    
}

class BasicComponent<PT>: Component where PT: RawRepresentable & CaseIterable & Displayable, PT.RawValue == Int {
    
    @Published var selectedProperty: PT?
    
    init(title: String, selectedProperty: PT?, parent: Component?) {
        self.selectedProperty = selectedProperty
        super.init(title: title, parent: parent)
    }
    
    override var properties: [String]? {
        PT.allCaseDisplayNames
    }
    
    override var selectedPropertyIndex: Int? {
        set {
            selectedProperty = .init(rawValue: newValue)
        }
        get {
            selectedProperty?.rawValue
        }
    }
    
}
