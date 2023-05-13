//
//  ObjectEditingParams.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.22.
//

import SwiftUI


struct ToolEditingParams {
    var activeElementIndexPath = IndexPath(index: 0)
}


struct ObjectComponentEditingParams {
    var activePropertyIndex = 0
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
    
    
    // MARK: Element editing params
    subscript(elementId elementId: AnyHashable, object: SPTObject, default defaultValue: @autoclosure () -> ObjectComponentEditingParams = .init()) -> ObjectComponentEditingParams {
        get {
            compoentEditingParams[object, default: .init()][elementId, default: defaultValue()]
        }
        set {
            compoentEditingParams[object, default: .init()][elementId] = newValue
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
