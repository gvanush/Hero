//
//  ComponentFloatPropertySelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


struct ComponentFloatPropertySelector<ID>: View
where ID: Hashable {
    
    let object: SPTObject
    let id: ID
    @Binding var value: Float
    let formatter: FloatFormatter
    
    @EnvironmentObject private var editingParams: ObjectEditingParams
    @EnvironmentObject private var userInteractionState: UserInteractionState
    
    var body: some View {
        FloatSelector(value: $value, scale: editingParam.scale, isSnappingEnabled: editingParam.isSnapping, formatter: formatter) { editingState in
            userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
        }
    }
    
    private var editingParam: Binding<ObjectPropertyFloatEditingParams> {
        $editingParams[floatPropertyId: id, object]
    }
    
}
