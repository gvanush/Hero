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


class PositionComponent: Component {
    
    @Published var activeAxis: Axis? = Axis.x
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Position", parent: parent)
    }
    
    override var properties: [String]? {
        Axis.allCaseDisplayNames
    }
    
    override var activePropertyIndex: Int? {
        set { activeAxis = .init(rawValue: newValue) }
        get { activeAxis?.rawValue }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


class OrientationComponent: Component {
    
    @Published var activeAxis: Axis? = Axis.x
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Orientation", parent: parent)
    }
    
    override var properties: [String]? {
        Axis.allCaseDisplayNames
    }
    
    override var activePropertyIndex: Int? {
        set { activeAxis = .init(rawValue: newValue) }
        get { activeAxis?.rawValue }
    }
    
    override func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}
