//
//  OrientationComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import SwiftUI


class OrientationComponent: BasicComponent<Axis> {
    
    static let title = "Oreintation"
    
    @SPTObservedComponent var orientation: SPTOrientation
    
    init(object: SPTObject, parent: Component?) {
        _orientation = SPTObservedComponent(object: object)
        
        super.init(title: OrientationComponent.title, selectedProperty: .x, parent: parent)
        
        _orientation.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { orientation.euler.rotation = SPTToRadFloat3(newValue) }
        get { SPTToDegFloat3(orientation.euler.rotation) }
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct OrientationComponentView: View {
    
    @ObservedObject var component: OrientationComponent
    @Binding var editedComponent: Component?
    
    var body: some View {
        Group {
            SceneEditableParam(title: "Base", value: String(format: "(%.1f°, %.1f°, %.1f°)", component.value.x, component.value.y, component.value.z)) {
                editedComponent = component
            }
            SceneEditableParam(title: "Animator", value: "Pan 0") {
                editedComponent = component
            }
        }
    }
}


struct EditOrientationComponentView: View {
    
    @ObservedObject var component: OrientationComponent
    @State private var scale = FloatSelector.Scale._10
    @State private var isSnappingEnabled = false
    
    var body: some View {
        if let axis = component.selectedProperty {
            FloatSelector(value: $component.value[axis.rawValue], scale: $scale, isSnappingEnabled: $isSnappingEnabled, measurementFormatter: .angleFormatter, formatterSubjectProvider: MeasurementFormatter.angleSubjectProvider)
                .transition(.identity)
                .id(axis.rawValue)
        }
    }
}
