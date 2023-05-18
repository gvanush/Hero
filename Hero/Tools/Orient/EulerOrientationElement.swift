//
//  EulerOrientationElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.05.23.
//

import SwiftUI


struct EulerOrientationElement: Element {
    
    static let keyPath = \SPTOrientation.euler
    
    enum Property: Int, ElementProperty {
        case x
        case y
        case z
    }
    
    let object: SPTObject
    let model: SPTOrientationModel
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @StateObject private var euler: SPTObservableComponentProperty<SPTOrientation, simd_float3>
    @ObjectElementActiveProperty var activeProperty: Property
    
    @State private var guideObject: SPTObject?
    
    init(object: SPTObject, model: SPTOrientationModel) {
        self.object = object
        self.model = model
        _euler = .init(wrappedValue: .init(object: object, keyPath: Self.keyPath))
        _activeProperty = .init(object: object, elementId: Self.keyPath)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .x:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.xInDegrees), value: $euler.xInDegrees, formatter: Formatters.angle)
            case .y:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.yInDegrees), value: $euler.yInDegrees, formatter: Formatters.angle)
            case .z:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.zInDegrees), value: $euler.zInDegrees, formatter: Formatters.angle)
            }
        }
        .tint(Color.primarySelectionColor)
    }
    
    var optionsView: some View {
        ObjectOrientationModelSelector(object: object)
    }
    
    func onActive() {
        setupGuideObject()
    }
    
    func onInactive() {
        removeGuideObject()
    }
    
    func onActivePropertyChange() {
        removeGuideObject()
        setupGuideObject()
    }
    
    func setupGuideObject() {

        let guide = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)
        
        switch activeProperty {
        case .x:
            SPTScale.make(.init(x: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
            switch model {
            case .eulerXYZ:
                SPTOrientation.make(.init(eulerX: 0.0, y: euler.y, z: euler.z), object: guide)
            case .eulerXZY:
                SPTOrientation.make(.init(eulerX: 0.0, z: euler.z, y: euler.y), object: guide)
            case .eulerYXZ:
                SPTOrientation.make(.init(eulerY: 0.0, x: 0.0, z: euler.z), object: guide)
            case .eulerZXY:
                SPTOrientation.make(.init(eulerZ: 0.0, x: 0.0, y: euler.y), object: guide)
            case .eulerYZX, .eulerZYX:
                break
            default:
                fatalError()
            }
            
        case .y:
            SPTScale.make(.init(y: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: MeshRegistry.util.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
            switch model {
            case .eulerXYZ:
                SPTOrientation.make(.init(eulerX: 0.0, y: 0.0, z: euler.z), object: guide)
            case .eulerYXZ:
                SPTOrientation.make(.init(eulerY: 0.0, x: euler.x, z: euler.z), object: guide)
            case .eulerYZX:
                SPTOrientation.make(.init(eulerY: 0.0, z: euler.z, x: euler.x), object: guide)
            case .eulerZYX:
                SPTOrientation.make(.init(eulerZ: 0.0, y: 0.0, x: euler.x), object: guide)
            case .eulerXZY, .eulerZXY:
                break
            default:
                break
            }
            
        case .z:
            SPTScale.make(.init(z: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId:MeshRegistry.util.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
            switch model {
            case .eulerXZY:
                SPTOrientation.make(.init(eulerX: 0.0, z: 0.0, y: euler.y), object: guide)
            case .eulerYZX:
                SPTOrientation.make(.init(eulerY: 0.0, z: 0.0, x: euler.x), object: guide)
            case .eulerZXY:
                SPTOrientation.make(.init(eulerZ: 0.0, x: euler.x, y: euler.y), object: guide)
            case .eulerZYX:
                SPTOrientation.make(.init(eulerZ: 0.0, y: euler.y, x: euler.x), object: guide)
            case .eulerXYZ, .eulerYXZ:
                break
            default:
                fatalError()
            }
        }

        guideObject = guide
    }
    
    func removeGuideObject() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
    var body: some View {
        elementBody
            .id(model)
    }
    
    var id: some Hashable {
        Self.keyPath
    }
    
    var title: String {
        "Orientation"
    }
    
    var subtitle: String? {
        model.displayName
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
