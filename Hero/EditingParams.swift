//
//  ObjectEditingParams.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.22.
//

import SwiftUI


struct ToolEditingParams {
    var activeComponentIndexPath = IndexPath()
}


struct ObjectComponentEditingParams {
    var activeProperyIndex = 0
}


struct ObjectPropertyFloatEditingParams {
    var scale = FloatSelector.Scale._1
    var isSnapping = true
}


class ObjectEditingParams: ObservableObject {
    
    // MARK: Tool editing params
    subscript(tool tool: Tool, object: SPTObject) -> ToolEditingParams {
        get {
            toolEditingParams[object, default: .init()][tool, default: .init()]
        }
        set {
            toolEditingParams[object, default: .init()][tool] = newValue
        }
    }
    
    @Published private var toolEditingParams = [SPTObject : [Tool : ToolEditingParams]]()
    
    
    // MARK: Component editing params
    subscript(componentId componentId: AnyHashable, object: SPTObject) -> ObjectComponentEditingParams {
        get {
            compoentEditingParams[object, default: .init()][componentId, default: .init()]
        }
        set {
            compoentEditingParams[object, default: .init()][componentId] = newValue
        }
    }
    
    @Published private var compoentEditingParams = [SPTObject : [AnyHashable : ObjectComponentEditingParams]]()
    
    
    // MARK: Property editing params
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
        toolEditingParams[duplicate] = toolEditingParams[original]
        compoentEditingParams[duplicate] = compoentEditingParams[original]
        floatEditingParams[duplicate] = floatEditingParams[original]
    }
    
    func onObjectDestroy(_ object: SPTObject) {
        toolEditingParams.removeValue(forKey: object)
        floatEditingParams.removeValue(forKey: object)
        compoentEditingParams.removeValue(forKey: object)
    }
}
