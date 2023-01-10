//
//  EditingParams.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.22.
//

import SwiftUI


struct ObjectPropertyFloatEditingParams {
    var scale = FloatSelector.Scale._1
    var isSnapping = true
}


class ObjectPropertyEditingParams: ObservableObject {
        
    subscript(floatPropertyId propertyId: AnyHashable, object: SPTObject) -> ObjectPropertyFloatEditingParams {
        get {
            floatEditingParams[object, default: .init()][propertyId, default: .init()]
        }
        set {
            floatEditingParams[object, default: .init()][propertyId] = newValue
        }
    }
    
    @Published private var floatEditingParams = [SPTObject : [AnyHashable : ObjectPropertyFloatEditingParams]]()
    
    // MARK: Object lifecycle
    func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
        floatEditingParams[duplicate] = floatEditingParams[original]
    }
    
    func onObjectDestroy(_ object: SPTObject) {
        floatEditingParams.removeValue(forKey: object)
    }
}
