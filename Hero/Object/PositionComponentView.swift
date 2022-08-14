//
//  PositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI


class PositionComponent: Component {
    
    static let title = "Position"
    
    let object: SPTObject
    lazy private(set) var base = BasePositionComponent(object: self.object, parent: self)
    lazy private(set) var animators = PositionAnimatorBindingsComponent(object: self.object, parent: self)
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: Self.title, parent: parent)
    }
    
    override var subcomponents: [Component]? { [base, animators] }
    
}


struct PositionComponentView: View {
    
    @ObservedObject var component: PositionComponent
    @Binding var editedComponent: Component?
    
    var body: some View {
        Section(component.title) {
            SceneEditableParam(title: component.base.title, value: String(format: "(%.1f, %.1f, %.1f)", component.base.value.x, component.base.value.y, component.base.value.z)) {
                editedComponent = component.base
            }
            NavigationLink(PositionAnimatorBindingsView.navigationTitle) {
                PositionAnimatorBindingsView(component: component.animators, editedComponent: $editedComponent)
            }
        }
    }
}


class BasePositionComponent: BasicComponent<Axis> {
    
    static let title = "Base"
    
    @SPTObservedComponent var position: SPTPosition
    
    init(object: SPTObject, parent: Component?) {
        
        _position = SPTObservedComponent(object: object)
        
        super.init(title: Self.title, selectedProperty: .x, parent: parent)
        
        _position.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { position.xyz = newValue }
        get { position.xyz }
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct EditBasePositionComponentView: View {
    
    @ObservedObject var component: BasePositionComponent
    @State private var scale = FloatField.Scale._1
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatField(value: $component.value[axis.rawValue], scale: $scale)
                .transition(.identity)
                .id(axis.rawValue)
        }
    }
}
