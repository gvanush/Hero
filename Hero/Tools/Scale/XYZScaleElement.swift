//
//  XYZScaleElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.05.23.
//

import SwiftUI


struct XYZScaleElement: Element {
    
    static let keyPath = \SPTScale.xyz
    
    enum Property: Int, ElementProperty {
        case x
        case y
        case z
    }
    
    let object: SPTObject
    
    @StateObject private var xyz: SPTObservableComponentProperty<SPTScale, simd_float3>
    @ObjectElementActiveProperty var activeProperty: Property
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var guideObject: SPTObject?
    
    init(object: SPTObject) {
        self.object = object
        _xyz = .init(wrappedValue: .init(object: object, keyPath: Self.keyPath))
        _activeProperty = .init(object: object, elementId: Self.keyPath)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .x:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.x), value: $xyz.x, formatter: Formatters.scale)
            case .y:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.y), value: $xyz.y, formatter: Formatters.scale)
            case .z:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.z), value: $xyz.z, formatter: Formatters.scale)
            }
        }
        .tint(Color.primarySelectionColor)
    }
    
    var optionsView: some View {
        ObjectScaleModelSelector(object: object)
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
        SPTOrientation.make(SPTOrientation.get(object: object), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)
        
        switch activeProperty {
        case .x:
            SPTScale.make(.init(x: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .y:
            SPTScale.make(.init(y: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: MeshRegistry.util.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .z:
            SPTScale.make(.init(z: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId:MeshRegistry.util.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
        }

        guideObject = guide
    }
    
    func removeGuideObject() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
    var id: some Hashable {
        Self.keyPath
    }
    
    var title: String {
        "Scale"
    }
    
    var subtitle: String? {
        "XYZ"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
