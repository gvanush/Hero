//
//  TransformationComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import SwiftUI


class TransformationComponent: Component {
    
    lazy private(set) var position = PositionComponent(parent: self)
    lazy private(set) var orientation = OrientationComponent(parent: self)
    lazy private(set) var scale = ScaleComponent(parent: self)
    
    init(parent: Component?) {
        super.init(title: "Transformation", parent: parent)
    }
    
    override var subcomponents: [Component]? { [position, orientation, scale] }
    
}


class PositionComponent: Component {
    
    @Published var activeAxis: Axis? = Axis.x
    
    init(parent: Component?) {
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
    
    init(parent: Component?) {
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
