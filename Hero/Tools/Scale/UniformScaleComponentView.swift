//
//  UniformScaleComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.12.22.
//

import SwiftUI


enum UniformScaleComponentProperty: Int, CaseIterable, Displayable {
    case uniform
}

class UniformScaleComponent: BasicComponent<UniformScaleComponentProperty> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let scaleFormatter = Formatters.scale
    
    private var guideObject: SPTObject?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(selectedProperty: .uniform, parent: parent)
        
    }
    
    var scale: SPTScale {
        get {
            SPTScale.get(object: object)
        }
        set {
            SPTScale.update(newValue, object: object)
        }
    }
 
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct UniformScaleComponentView: View {
    
    @ObservedObject var component: UniformScaleComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        FloatSelector(value: $component.scale.uniform, scale: $editingParams[uniformScaleOf: component.object].uniform.scale, isSnappingEnabled: $editingParams[uniformScaleOf: component.object].uniform.isSnapping, formatter: component.scaleFormatter) { editingState in
            userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
}
