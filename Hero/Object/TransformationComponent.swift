//
//  TransformationComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import SwiftUI


class TransformationComponent: Component {
    
    let object: SPTObject
    lazy private(set) var position = PositionComponent(object: self.object, parent: self)
    lazy private(set) var orientation = OrientationComponent(object: self.object, parent: self)
    lazy private(set) var scale = ScaleComponent(object: self.object, parent: self)
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Transformation", parent: parent)
    }
    
    override var subcomponents: [Component]? { [position, orientation, scale] }
    
}


class PositionComponent: BasicComponent<Axis> {
    
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Position", selectedProperty: .x, parent: parent)
        
        SPTAddPositionWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<PositionComponent>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
    }
    
    deinit {
        SPTRemovePositionWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
    
    var value: simd_float3 {
        set { SPTUpdatePosition(object, SPTPosition(variantTag: .XYZ, .init(xyz: newValue))) }
        get { SPTGetPosition(object).xyz }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


class OrientationComponent: BasicComponent<Axis> {
    
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Orientation", selectedProperty: .x, parent: parent)
        
        SPTAddOrientationWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<OrientationComponent>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
    }
    
    deinit {
        SPTRemoveOrientationWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
    
    var value: simd_float3 {
        set {
            var orientation = SPTGetOrientation(object)
            orientation.euler.rotation = SPTToRadFloat3(newValue)
            SPTUpdateOrientation(object, orientation)
        }
        get { SPTToDegFloat3(SPTGetOrientation(object).euler.rotation) }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}

class ScaleComponent: BasicComponent<Axis> {
    
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Scale", selectedProperty: .x, parent: parent)
        
        SPTAddScaleWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer in
            let me = Unmanaged<ScaleComponent>.fromOpaque(observer!).takeUnretainedValue()
            me.objectWillChange.send()
        })
    }
    
    deinit {
        SPTRemoveScaleWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
    
    var value: simd_float3 {
        set { SPTUpdateScale(object, newValue) }
        get { SPTGetScale(object) }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}
