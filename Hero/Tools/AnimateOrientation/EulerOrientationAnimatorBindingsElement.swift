//
//  EulerOrientationAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.05.23.
//

import SwiftUI


struct EulerOrientationAnimatorBindingsElement: Element {
    
    let object: SPTObject
    let twinObject: SPTObject
    
    @StateObject private  var twinEuler: SPTObservableComponentProperty<SPTOrientation, simd_float3>
    
    @State private var xAxisObject: SPTObject!
    @State private var yAxisObject: SPTObject!
    @State private var zAxisObject: SPTObject!
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    init(object: SPTObject, twinObject: SPTObject) {
        self.object = object
        self.twinObject = twinObject
        _twinEuler = .init(wrappedValue: .init(object: twinObject, keyPath: \.euler))
    }
    
    var content: some Element {
        RotationPropertyAnimatorBindingElement(title: "X", normAxisDirection: xNormAxis, propertyValue: $twinEuler.x, animatableProperty: .eulerOrientationX, object: object, guideColor: .xAxis, activeGuideColor: .xAxisLight)
        RotationPropertyAnimatorBindingElement(title: "Y", normAxisDirection: yNormAxis, propertyValue: $twinEuler.y, animatableProperty: .eulerOrientationY, object: object, guideColor: .yAxis, activeGuideColor: .yAxisLight)
        RotationPropertyAnimatorBindingElement(title: "Z", normAxisDirection: zNormAxis, propertyValue: $twinEuler.z, animatableProperty: .eulerOrientationZ, object: object, guideColor: .zAxis, activeGuideColor: .zAxisLight)
    }
    
    var xNormAxis: simd_float3 {
        
        let orientation = SPTOrientation.get(object: object)
        var matrix = matrix_identity_float3x3
        switch orientation.model {
        case .eulerXYZ:
            matrix = SPTMatrix3x3CreateEulerZOrientation(orientation.euler.z) * SPTMatrix3x3CreateEulerYOrientation(orientation.euler.y)
        case .eulerXZY:
            matrix = SPTMatrix3x3CreateEulerYOrientation(orientation.euler.y) * SPTMatrix3x3CreateEulerZOrientation(orientation.euler.z)
        case .eulerYXZ:
            matrix = SPTMatrix3x3CreateEulerZOrientation(orientation.euler.z)
        case .eulerZXY:
            matrix = SPTMatrix3x3CreateEulerYOrientation(orientation.euler.y)
        case .eulerZYX, .eulerYZX:
            break
        default:
            fatalError()
        }
        
        return matrix * .right
    }
    
    var yNormAxis: simd_float3 {
        
        let orientation = SPTOrientation.get(object: object)
        var matrix = matrix_identity_float3x3
        switch orientation.model {
        case .eulerYXZ:
            matrix = SPTMatrix3x3CreateEulerZOrientation(orientation.euler.z) * SPTMatrix3x3CreateEulerXOrientation(orientation.euler.x)
        case .eulerYZX:
            matrix = SPTMatrix3x3CreateEulerXOrientation(orientation.euler.x) * SPTMatrix3x3CreateEulerZOrientation(orientation.euler.z)
        case .eulerXYZ:
            matrix = SPTMatrix3x3CreateEulerZOrientation(orientation.euler.z)
        case .eulerZYX:
            matrix = SPTMatrix3x3CreateEulerXOrientation(orientation.euler.x)
        case .eulerZXY, .eulerXZY:
            break
        default:
            fatalError()
        }
        
        return matrix * .up
    }
    
    var zNormAxis: simd_float3 {
        
        let orientation = SPTOrientation.get(object: object)
        var matrix = matrix_identity_float3x3
        switch orientation.model {
        case .eulerZXY:
            matrix = SPTMatrix3x3CreateEulerYOrientation(orientation.euler.y) * SPTMatrix3x3CreateEulerXOrientation(orientation.euler.x)
        case .eulerZYX:
            matrix = SPTMatrix3x3CreateEulerXOrientation(orientation.euler.x) * SPTMatrix3x3CreateEulerYOrientation(orientation.euler.y)
        case .eulerXZY:
            matrix = SPTMatrix3x3CreateEulerYOrientation(orientation.euler.y)
        case .eulerYZX:
            matrix = SPTMatrix3x3CreateEulerXOrientation(orientation.euler.x)
        case .eulerYXZ, .eulerXYZ:
            break
        default:
            fatalError()
        }
        
        return matrix * .backward
    }
    
    func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxis.rgba, polylineId: MeshRegistry.util.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId:MeshRegistry.util.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
    }
    
    func onClose() {
        SPTPolylineLook.destroy(object: xAxisObject)
        SPTPolylineLook.destroy(object: yAxisObject)
        SPTPolylineLook.destroy(object: zAxisObject)
    }
    
    func onAwake() {
        let origin = SPTPosition.get(object: object)
        
        xAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: xAxisObject)
        
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: yAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 500.0, 1.0)), object: yAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: yAxisObject)
        
        zAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: zAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 1.0, 500.0)), object: zAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: zAxisObject)
        
        let orientation = SPTOrientation.get(object: object)
     
        switch orientation.model {
        case .eulerXYZ:
            SPTOrientation.make(.init(eulerX: 0.0, y: orientation.euler.y, z: orientation.euler.z), object: xAxisObject)
            SPTOrientation.make(.init(eulerX: 0.0, y: 0.0, z: orientation.euler.z), object: yAxisObject)
        case .eulerXZY:
            SPTOrientation.make(.init(eulerX: 0.0, z: orientation.euler.z, y: orientation.euler.y), object: xAxisObject)
            SPTOrientation.make(.init(eulerX: 0.0, z: 0.0, y: orientation.euler.y), object: zAxisObject)
        case .eulerYXZ:
            SPTOrientation.make(.init(eulerY: 0.0, x: 0.0, z: orientation.euler.z), object: xAxisObject)
            SPTOrientation.make(.init(eulerY: 0.0, x: orientation.euler.x, z: orientation.euler.z), object: yAxisObject)
        case .eulerYZX:
            SPTOrientation.make(.init(eulerY: 0.0, z: orientation.euler.z, x: orientation.euler.x), object: yAxisObject)
            SPTOrientation.make(.init(eulerY: 0.0, z: 0.0, x: orientation.euler.x), object: zAxisObject)
        case .eulerZXY:
            SPTOrientation.make(.init(eulerZ: 0.0, x: 0.0, y: orientation.euler.y), object: xAxisObject)
            SPTOrientation.make(.init(eulerZ: 0.0, x: orientation.euler.x, y: orientation.euler.y), object: zAxisObject)
        case .eulerZYX:
            SPTOrientation.make(.init(eulerZ: 0.0, y: 0.0, x: orientation.euler.x), object: yAxisObject)
            SPTOrientation.make(.init(eulerZ: 0.0, y: orientation.euler.y, x: orientation.euler.x), object: zAxisObject)
        default:
            fatalError()
        }
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(xAxisObject)
        SPTSceneProxy.destroyObject(yAxisObject)
        SPTSceneProxy.destroyObject(zAxisObject)
    }
    
    var id: some Hashable {
        \SPTOrientation.euler
    }
    
    var title: String {
        "Orientation"
    }
    
    var subtitle: String? {
        "Euler"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
