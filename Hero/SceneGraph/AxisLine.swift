//
//  AxisLine.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.05.23.
//

import Foundation


class AxisLine: LocatableObject, ScalableObject, PolylineObject, DepthBiasedLineObject {
    
    let sptObject: SPTObject
    var _scene: MainScene!
    
    init(sptObject: SPTObject, length: Float, axis: Axis = .x, color: UIColor = .black, thickness: Float = 1.0, lookCategories: LookCategories = .all) {
        self.sptObject = sptObject
        self.axis = axis
        
        _buildLocatableObject()
        _buildScalableObject(scale: .init(uniform: length / 2.0))
        _buildPolylineObject(polylineLook: .init(color: color.rgba, polylineId: polylineId, thickness: thickness, categories: lookCategories.rawValue))
        _buildDepthBiasedLineObject(bias: .guideLineLayer3)
    }
    
    var length: Float {
        get {
            scale.uniform * 2.0
        }
        set {
            scale.uniform = newValue / 2.0
        }
    }
    
    var color: UIColor {
        get {
            .init(rgba: polylineLook.color)
        }
        set {
            polylineLook.color = newValue.rgba
        }
    }
    
    var axis: Axis {
        didSet {
            polylineLook.polylineId = polylineId
        }
    }
    
    var thickness: Float {
        get {
            polylineLook.thickness
        }
        set {
            polylineLook.thickness = newValue
        }
    }
    
    var lookCategories: LookCategories {
        get {
            .init(rawValue: polylineLook.categories)
        }
        set {
            polylineLook.categories = newValue.rawValue
        }
    }
    
    private var polylineId: SPTPolylineId {
        switch axis {
        case .x:
            return MeshRegistry.util.xAxisLineMeshId
        case .y:
            return MeshRegistry.util.yAxisLineMeshId
        case .z:
            return MeshRegistry.util.zAxisLineMeshId
        }
    }
}
