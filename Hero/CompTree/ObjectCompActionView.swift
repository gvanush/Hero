//
//  ObjectCompActionView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.03.23.
//

import SwiftUI

struct ObjectPropertyInfo {
    
    enum TypeInfo {
        case float(value: Binding<Float>, formatter: FloatFormatter)
    }
    
    let id: AnyHashable
    let typeInfo: TypeInfo
    let controlTintColor: Color
}



protocol ObjectCompControllerProtocol: CompControllerProtocol {
    
    var object: SPTObject { get }
    
    func infoFor(_ property: Property) -> ObjectPropertyInfo
    
}


typealias ObjectCompController = CompControllerBase & ObjectCompControllerProtocol

struct ObjectCompActionView: View {
    
    @ObservedObject var controller: CompControllerBase
    private let object: SPTObject
    private let propertyInfoGetter: (Int) -> ObjectPropertyInfo
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    init<C>(controller: C) where C: ObjectCompController {
        self.controller = controller
        self.object = controller.object
        self.propertyInfoGetter = { activePropertyIndex in
            controller.infoFor(.init(rawValue: activePropertyIndex)!)
        }
    }
    
    var body: some View {
        if let propInfo = activePropertyInfo {
            Group {
                switch propInfo.typeInfo {
                case .float(let value, let formatter):
                    FloatSelector(value: value,
                                  scale: $editingParams[floatPropertyId: propInfo.id, object].scale,
                                  isSnappingEnabled: $editingParams[floatPropertyId: propInfo.id, object].isSnapping,
                                  formatter: formatter
                    ) { editingState in
                        userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                    }
                }
            }
            .tint(propInfo.controlTintColor)
            .transition(.identity)
            .id(propInfo.id)
        }
    }
    
    var activePropertyInfo: ObjectPropertyInfo? {
        guard let activePropertyIndex = controller.activePropertyIndex else {
            return nil
        }
        return propertyInfoGetter(activePropertyIndex)
    }
}
