//
//  CartesianPositionElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.04.23.
//

import SwiftUI


struct CartesianPositionElement<C>: ComponentElement
where C: SPTObservableComponent {
    
    enum Property: Int, ElementProperty {
        case x
        case y
        case z
    }
    
    let object: SPTObject
    let keyPath: KeyPath<C, simd_float3>
    @Binding private var cartesian: simd_float3
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    @ComponentActiveProperty var activeProperty: Property
    @State private var guideObject: SPTObject?
    
    
    init(title: String = "Position", subtitle: String? = "Cartesian", object: SPTObject, keyPath: WritableKeyPath<C, simd_float3>, position: Binding<simd_float3>) {
        self.title = title
        self.subtitle = subtitle
        self.object = object
        self.keyPath = keyPath
        _cartesian = position
        _activeProperty = .init(object: object, componentId: keyPath)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .x:
                ComponentFloatPropertySelector(object: object, id: keyPath.appending(path: \.x), value: $cartesian.x)
            case .y:
                ComponentFloatPropertySelector(object: object, id: keyPath.appending(path: \.y), value: $cartesian.y)
            case .z:
                ComponentFloatPropertySelector(object: object, id: keyPath.appending(path: \.z), value: $cartesian.z)
            }
        }
        .tint(controlTint)
    }
    
    func onActivePropertyChange() {
        removeGuideObject()
        setupGuideObject()
    }
    
    func onActive() {
        setupGuideObject()
    }
    
    func onInactive() {
        removeGuideObject()
    }
    
    func onDisclose() {
        onDiscloseCallback()
    }
    
    func onClose() {
        onCloseCallback()
    }
    
    private func setupGuideObject() {

        let guide = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cartesian), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)

        switch activeProperty {
        case .x:
            SPTScale.make(.init(x: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .y:
            SPTScale.make(.init(y: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .z:
            SPTScale.make(.init(z: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
        }

        guideObject = guide
    }
    
    private func removeGuideObject() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
    var id: some Hashable {
        keyPath
    }
    
    func controlTint(_ color: Color) -> Self {
        var copy = self
        copy.controlTint = color
        return copy
    }
    
    func onDisclose(_ callback: @escaping () -> Void) -> Self {
        var copy = self
        copy.onDiscloseCallback = callback
        return copy
    }
    
    func onClose(_ callback: @escaping () -> Void) -> Self {
        var copy = self
        copy.onCloseCallback = callback
        return copy
    }
    
    let title: String
    var subtitle: String?
    
    private var controlTint: Color = .primarySelectionColor
    private var onDiscloseCallback = {}
    private var onCloseCallback = {}
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace

}
