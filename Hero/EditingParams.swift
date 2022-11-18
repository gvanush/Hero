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

fileprivate protocol ObjectPropertyVectorEditingParams {
    var x: ObjectPropertyFloatEditingParams { get set }
    var y: ObjectPropertyFloatEditingParams { get set }
    var z: ObjectPropertyFloatEditingParams { get set }
}

extension ObjectPropertyVectorEditingParams {
    
    subscript(axis: Axis) -> ObjectPropertyFloatEditingParams {
        set {
            switch axis {
            case .x:
                x = newValue
            case .y:
                y = newValue
            case .z:
                z = newValue
            }
        }
        get {
            switch axis {
            case .x:
                return x
            case .y:
                return y
            case .z:
                return z
            }
        }
    }
    
}

struct ObjectPropertyPositionEditingParams: ObjectPropertyVectorEditingParams {
    var x = ObjectPropertyFloatEditingParams()
    var y = ObjectPropertyFloatEditingParams()
    var z = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyScaleEditingParams: ObjectPropertyVectorEditingParams {
    var x = ObjectPropertyFloatEditingParams()
    var y = ObjectPropertyFloatEditingParams()
    var z = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyRotationEditingParams: ObjectPropertyVectorEditingParams {
    var x = ObjectPropertyFloatEditingParams()
    var y = ObjectPropertyFloatEditingParams()
    var z = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyPositionBindingEditingParams {
    var valueAt0 = ObjectPropertyFloatEditingParams()
    var valueAt1 = ObjectPropertyFloatEditingParams()
}

class ObjectPropertyEditingParams: ObservableObject {

    // MARK: Position
    @Published private var positionParams = [SPTObject : ObjectPropertyPositionEditingParams]()
    
    subscript(positionOf object: SPTObject, axis axis: Axis) -> ObjectPropertyFloatEditingParams {
        get {
            positionParams[object, default: .init()][axis]
        }
        set {
            var params = positionParams[object, default: .init()]
            params[axis] = newValue
            positionParams[object] = params
        }
    }
    
    // MARK: Scale
    @Published private var scaleParams = [SPTObject : ObjectPropertyScaleEditingParams]()
    
    subscript(scaleOf object: SPTObject, axis axis: Axis) -> ObjectPropertyFloatEditingParams {
        get {
            scaleParams[object, default: .init()][axis]
        }
        set {
            var params = scaleParams[object, default: .init()]
            params[axis] = newValue
            scaleParams[object] = params
        }
    }
    
    // MARK: Rotation
    @Published private var rotationParams = [SPTObject : ObjectPropertyScaleEditingParams]()
    
    subscript(rotationOf object: SPTObject, axis axis: Axis) -> ObjectPropertyFloatEditingParams {
        get {
            rotationParams[object, default: .init()][axis]
        }
        set {
            var params = rotationParams[object, default: .init()]
            params[axis] = newValue
            rotationParams[object] = params
        }
    }
    
    // MARK: Position binding
    @Published private var positionBindingParams = [SPTObject : ObjectPropertyPositionBindingEditingParams]()
    
    subscript(positionBindingOf object: SPTObject) -> ObjectPropertyPositionBindingEditingParams {
        get {
            positionBindingParams[object, default: .init()]
        }
        set {
            positionBindingParams[object] = newValue
        }
    }
    
    // MARK: Object lifecycle
    func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
        positionParams[duplicate] = positionParams[original]
        scaleParams[duplicate] = scaleParams[original]
        rotationParams[duplicate] = rotationParams[original]
        positionBindingParams[duplicate] = positionBindingParams[original]
    }
    
    func onObjectDestroy(_ object: SPTObject) {
        positionParams.removeValue(forKey: object)
        scaleParams.removeValue(forKey: object)
        rotationParams.removeValue(forKey: object)
        positionBindingParams.removeValue(forKey: object)
    }
}
