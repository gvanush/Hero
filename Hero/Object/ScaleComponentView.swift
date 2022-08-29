//
//  ScaleComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI


class ScaleComponent: BasicComponent<Axis> {
    
    static let title = "Scale"
    
    @SPTObservedComponent var scale: SPTScale
    
    init(object: SPTObject, parent: Component?) {
        _scale = SPTObservedComponent(object: object)
        
        super.init(title: Self.title, selectedProperty: .x, parent: parent)
        
        _scale.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { scale.xyz = newValue }
        get { scale.xyz }
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct ScaleComponentView: View {
    
    @ObservedObject var component: ScaleComponent
    @Binding var editedComponent: Component?
    
    var body: some View {
        Group {
            SceneEditableParam(title: "Base", value: String(format: "(%.1f, %.1f, %.1f)", component.value.x, component.value.y, component.value.z)) {
                editedComponent = component
            }
            SceneEditableParam(title: "Animator", value: "Pan 0") {
                editedComponent = component
            }
        }
    }
}


struct EditScaleComponentView: View {
    
    @ObservedObject var component: ScaleComponent
    @State private var scale = FloatSelector.Scale._0_1
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatSelector(value: $component.value[axis.rawValue], scale: $scale)
                .transition(.identity)
                .id(axis.rawValue)
        }
    }
}
