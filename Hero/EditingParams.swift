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

protocol ObjectPropertyVectorEditingParams {
    
    associatedtype P
    
    var x: P { get set }
    var y: P { get set }
    var z: P { get set }
}

extension ObjectPropertyVectorEditingParams {
    
    subscript(axis: Axis) -> P {
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

struct AnimatorBindingEditingParams {
    var valueAt0 = ObjectPropertyFloatEditingParams()
    var valueAt1 = ObjectPropertyFloatEditingParams()
}


struct ObjectPropertyCartesianPositionEditingParams: ObjectPropertyVectorEditingParams {
    var x = ObjectPropertyFloatEditingParams()
    var y = ObjectPropertyFloatEditingParams()
    var z = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyLinearPositionEditingParams {
    var origin = ObjectPropertyCartesianPositionEditingParams()
    var target = ObjectPropertyCartesianPositionEditingParams()
    var factor = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyCylindricalPositionEditingParams {
    var origin = ObjectPropertyCartesianPositionEditingParams()
    var longitude = ObjectPropertyFloatEditingParams()
    var radius = ObjectPropertyFloatEditingParams()
    var height = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertySphericalPositionEditingParams {
    var origin = ObjectPropertyCartesianPositionEditingParams()
    var longitude = ObjectPropertyFloatEditingParams()
    var latitude = ObjectPropertyFloatEditingParams()
    var radius = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyXYZScaleEditingParams: ObjectPropertyVectorEditingParams {
    var x = ObjectPropertyFloatEditingParams()
    var y = ObjectPropertyFloatEditingParams()
    var z = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyUniformScaleEditingParams {
    var uniform = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyRotationEditingParams: ObjectPropertyVectorEditingParams {
    var x = ObjectPropertyFloatEditingParams()
    var y = ObjectPropertyFloatEditingParams()
    var z = ObjectPropertyFloatEditingParams()
}

struct ObjectPropertyCartesianPositionAnimatorBindingEditingParams: ObjectPropertyVectorEditingParams {
    var x = AnimatorBindingEditingParams()
    var y = AnimatorBindingEditingParams()
    var z = AnimatorBindingEditingParams()
}

struct ObjectPropertyLinearPositionAnimatorBindingEditingParams {
    var offset = AnimatorBindingEditingParams()
}

struct ObjectPropertyCylindricalPositionAnimatorBindingEditingParams {
    var radius = AnimatorBindingEditingParams()
    var longitude = AnimatorBindingEditingParams()
    var height = AnimatorBindingEditingParams()
}

struct ObjectPropertySphericalPositionAnimatorBindingEditingParams {
    var radius = AnimatorBindingEditingParams()
    var longitude = AnimatorBindingEditingParams()
    var latitude = AnimatorBindingEditingParams()
}

class ObjectPropertyEditingParams: ObservableObject {

    // MARK: Position
    @Published private var cartesianPositionParams = [SPTObject : ObjectPropertyCartesianPositionEditingParams]()
    
    subscript(cartesianPositionOf object: SPTObject) -> ObjectPropertyCartesianPositionEditingParams {
        get {
            cartesianPositionParams[object, default: .init()]
        }
        set {
            cartesianPositionParams[object] = newValue
        }
    }
    
    @Published private var linearPositionParams = [SPTObject : ObjectPropertyLinearPositionEditingParams]()
    
    subscript(linearPositionOf object: SPTObject) -> ObjectPropertyLinearPositionEditingParams {
        get {
            linearPositionParams[object, default: .init()]
        }
        set {
            linearPositionParams[object] = newValue
        }
    }
    
    @Published private var cylindricalPositionParams = [SPTObject : ObjectPropertyCylindricalPositionEditingParams]()
    
    subscript(cylindricalPositionOf object: SPTObject) -> ObjectPropertyCylindricalPositionEditingParams {
        get {
            cylindricalPositionParams[object, default: .init()]
        }
        set {
            cylindricalPositionParams[object] = newValue
        }
    }
    
    @Published private var sphericalPositionParams = [SPTObject : ObjectPropertySphericalPositionEditingParams]()
    
    subscript(sphericalPositionOf object: SPTObject) -> ObjectPropertySphericalPositionEditingParams {
        get {
            sphericalPositionParams[object, default: .init()]
        }
        set {
            sphericalPositionParams[object] = newValue
        }
    }
    
    // MARK: Scale
    @Published private var xyzScaleParams = [SPTObject : ObjectPropertyXYZScaleEditingParams]()
    
    subscript(xyzScaleOf object: SPTObject) -> ObjectPropertyXYZScaleEditingParams {
        get {
            xyzScaleParams[object, default: .init()]
        }
        set {
            xyzScaleParams[object] = newValue
        }
    }
    
    @Published private var uniformScaleParams = [SPTObject : ObjectPropertyUniformScaleEditingParams]()

    subscript(uniformScaleOf object: SPTObject) -> ObjectPropertyUniformScaleEditingParams {
        get {
            uniformScaleParams[object, default: .init()]
        }
        set {
            uniformScaleParams[object] = newValue
        }
    }
    
    // MARK: Rotation
    @Published private var rotationParams = [SPTObject : ObjectPropertyRotationEditingParams]()
    
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
    @Published private var cartesianPositionBindingParams = [SPTObject : ObjectPropertyCartesianPositionAnimatorBindingEditingParams]()
    
    subscript(cartesianPositionBindingOf object: SPTObject) -> ObjectPropertyCartesianPositionAnimatorBindingEditingParams {
        get {
            cartesianPositionBindingParams[object, default: .init()]
        }
        set {
            cartesianPositionBindingParams[object] = newValue
        }
    }
    
    @Published private var linearPositionBindingParams = [SPTObject : ObjectPropertyLinearPositionAnimatorBindingEditingParams]()

    subscript(linearPositionBindingOf object: SPTObject) -> ObjectPropertyLinearPositionAnimatorBindingEditingParams {
        get {
            linearPositionBindingParams[object, default: .init()]
        }
        set {
            linearPositionBindingParams[object] = newValue
        }
    }
    
    @Published private var cylindricalPositionBindingParams = [SPTObject : ObjectPropertyCylindricalPositionAnimatorBindingEditingParams]()

    subscript(cylindricalPositionBindingOf object: SPTObject) -> ObjectPropertyCylindricalPositionAnimatorBindingEditingParams {
        get {
            cylindricalPositionBindingParams[object, default: .init()]
        }
        set {
            cylindricalPositionBindingParams[object] = newValue
        }
    }
    
    @Published private var sphericalPositionBindingParams = [SPTObject : ObjectPropertySphericalPositionAnimatorBindingEditingParams]()

    subscript(sphericalPositionBindingOf object: SPTObject) -> ObjectPropertySphericalPositionAnimatorBindingEditingParams {
        get {
            sphericalPositionBindingParams[object, default: .init()]
        }
        set {
            sphericalPositionBindingParams[object] = newValue
        }
    }
    
    // MARK: Object lifecycle
    func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
        cartesianPositionParams[duplicate] = cartesianPositionParams[original]
        linearPositionParams[duplicate] = linearPositionParams[original]
        cylindricalPositionParams[duplicate] = cylindricalPositionParams[original]
        sphericalPositionParams[duplicate] = sphericalPositionParams[original]
        
        xyzScaleParams[duplicate] = xyzScaleParams[original]
        rotationParams[duplicate] = rotationParams[original]
        cartesianPositionBindingParams[duplicate] = cartesianPositionBindingParams[original]
        linearPositionBindingParams[duplicate] = linearPositionBindingParams[original]
        cylindricalPositionBindingParams[duplicate] = cylindricalPositionBindingParams[original]
        sphericalPositionBindingParams[duplicate] = sphericalPositionBindingParams[original]
    }
    
    func onObjectDestroy(_ object: SPTObject) {
        cartesianPositionParams.removeValue(forKey: object)
        linearPositionParams.removeValue(forKey: object)
        cylindricalPositionParams.removeValue(forKey: object)
        sphericalPositionParams.removeValue(forKey: object)
        
        xyzScaleParams.removeValue(forKey: object)
        rotationParams.removeValue(forKey: object)
        cartesianPositionBindingParams.removeValue(forKey: object)
        linearPositionBindingParams.removeValue(forKey: object)
        cylindricalPositionBindingParams.removeValue(forKey: object)
        sphericalPositionBindingParams.removeValue(forKey: object)
    }
}
