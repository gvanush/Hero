//
//  EulerOrientationAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.23.
//

import Foundation

fileprivate let angleDefaultValue = Float.pi * 0.25

class EulerOrientationAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var xAxisObject: SPTObject!
    private var yAxisObject: SPTObject!
    private var zAxisObject: SPTObject!

    typealias FieldComponent = AnimatorBindingSetupComponent<EulerOrientationFieldAnimatorBindingComponent>
    
    lazy private(set) var x = FieldComponent(animatableProperty: .eulerOrientationX, defaultValueAt0: -angleDefaultValue, defaultValueAt1: angleDefaultValue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = FieldComponent(animatableProperty: .eulerOrientationY, defaultValueAt0: -angleDefaultValue, defaultValueAt1: angleDefaultValue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = FieldComponent(animatableProperty: .eulerOrientationZ, defaultValueAt0: -angleDefaultValue, defaultValueAt1: angleDefaultValue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
        
        setupAxes()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(xAxisObject)
        SPTSceneProxy.destroyObject(yAxisObject)
        SPTSceneProxy.destroyObject(zAxisObject)
    }
    
    override var title: String {
        "Animators"
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxis.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: xAxisObject)
        SPTPolylineLook.destroy(object: yAxisObject)
        SPTPolylineLook.destroy(object: zAxisObject)
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
    private func setupAxes() {
        
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
    
}
