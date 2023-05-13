//
//  ObjectFloatPropertySelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


struct ObjectFloatPropertySelector<ID>: View
where ID: Hashable {
    
    let object: SPTObject
    let id: ID
    @Binding var value: Float
    let formatter: FloatFormatter
    
    init(object: SPTObject, id: ID, value: Binding<Float>, formatter: FloatFormatter = Formatters.genericFloat) {
        self.object = object
        self.id = id
        _value = value
        self.formatter = formatter
    }
    
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
