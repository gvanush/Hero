//
//  ShadingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import SwiftUI


class ShadeComponent: BasicComponent<ShadeComponent.Property>, BasicToolSelectedObjectRootComponent {

    enum Property: Int, DistinctValueSet, Displayable {
        case shininess
    }
    
    typealias ColorComponent = ObjectColorComponent<SPTMeshLook>
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @SPTObservedComponent var meshLook: SPTMeshLook
    
    lazy private(set) var color = ColorComponent(keyPath: \.shading.blinnPhong.color, object: object, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        _meshLook = .init(object: object)
        
        super.init(selectedProperty: .shininess, parent: parent)
        
        _meshLook.publisher = self.objectWillChange
    }
    
    override var title: String {
        "Shade"
    }
    
    override var subcomponents: [Component]? { [color] }
    
}

struct ShadeComponentView: View {
    
    @ObservedObject var component: ShadeComponent
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .shininess:
                FloatSlider(value: $component.meshLook.shading.blinnPhong.shininess) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
                .tint(.primarySelectionColor)
            }
        }
        .transition(.identity)
    }
}
