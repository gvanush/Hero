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
    
    @SPTObservedPosition var position: SPTPosition
    
    init(object: SPTObject, parent: Component?) {
        
        _position = SPTObservedPosition(object: object)
        
        super.init(title: "Position", selectedProperty: .x, parent: parent)
        
        _position.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { position.xyz = newValue }
        get { position.xyz }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


class OrientationComponent: BasicComponent<Axis> {
    
    @SPTObservedOrientation var orientation: SPTOrientation
    
    init(object: SPTObject, parent: Component?) {
        _orientation = SPTObservedOrientation(object: object)
        
        super.init(title: "Orientation", selectedProperty: .x, parent: parent)
        
        _orientation.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { orientation.euler.rotation = SPTToRadFloat3(newValue) }
        get { SPTToDegFloat3(orientation.euler.rotation) }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}

class ScaleComponent: BasicComponent<Axis> {
    
    @SPTObservedScale var scale: SPTScale
    
    init(object: SPTObject, parent: Component?) {
        _scale = SPTObservedScale(object: object)
        
        super.init(title: "Scale", selectedProperty: .x, parent: parent)
        
        _scale.publisher = self.objectWillChange
    }
    
    var value: simd_float3 {
        set { scale.xyz = newValue }
        get { scale.xyz }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}
