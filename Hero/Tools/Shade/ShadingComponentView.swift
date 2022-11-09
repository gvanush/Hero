//
//  ShadingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import SwiftUI


class ShadingComponent: BasicComponent<ShadingComponent.Property>, BasicToolSelectedObjectRootComponent {

    enum Property: Int, DistinctValueSet, Displayable {
        case shininess
    }
    
    typealias ColorComponent = ObjectColorComponent<SPTMeshLook>
    
    struct EditingParams {
        var color = ColorComponent.EditingParams()
    }
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    private let initialColorEditingParams: ColorComponent.EditingParams
    
    @SPTObservedComponent var meshLook: SPTMeshLook
    
    lazy private(set) var color = ColorComponent(editingParams: initialColorEditingParams, keyPath: \.shading.blinnPhong.color, object: object, parent: self)
    
    required init(editingParams: EditingParams, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        self.initialColorEditingParams = editingParams.color
        _meshLook = .init(object: object)
        
        super.init(selectedProperty: .shininess, parent: parent)
        
        _meshLook.publisher = self.objectWillChange
    }
    
    override var title: String {
        "Shading"
    }
    
    override var subcomponents: [Component]? { [color] }
    
    var editingParams: EditingParams {
        .init(color: color.editingParams)
    }
    
}

struct ShadingComponentView: View {
    
    @ObservedObject var component: ShadingComponent
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .shininess:
                FloatSlider(value: $component.meshLook.shading.blinnPhong.shininess)
                    .tint(.primarySelectionColor)
            case .none:
                EmptyView()
            }
        }
        .transition(.identity)
    }
}
