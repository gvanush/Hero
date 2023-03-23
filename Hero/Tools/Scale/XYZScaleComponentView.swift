//
//  XYZScaleComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.12.22.
//

import SwiftUI


class XYZScaleComponent: BasicComponent<Axis> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let scaleFormatter = Formatters.scale
    
    private var guideObject: SPTObject?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(selectedProperty: .x, parent: parent)
        
    }
    
    var scale: SPTScale {
        get {
            SPTScale.get(object: object)
        }
        set {
            SPTScale.update(newValue, object: object)
        }
    }
    
    override var selectedProperty: Axis {
        didSet {
            if isActive {
                removeGuideObject()
                setupGuideObject()
            }
        }
    }
    
    override func onActive() {
        setupGuideObject()
    }
    
    override func onInactive() {
        removeGuideObject()
    }
    
    
    func setupGuideObject() {

        let guide = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guide)
        SPTOrientation.make(SPTOrientation.get(object: object), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)
        
        switch selectedProperty {
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
    
    func removeGuideObject() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct XYZScaleComponentView: View {
    
    @ObservedObject var component: XYZScaleComponent
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .x:
                FloatSelector(value: $component.scale.xyz.x, scale: editingParam(\.x).scale, isSnappingEnabled: editingParam(\.x).isSnapping, formatter: component.scaleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .y:
                FloatSelector(value: $component.scale.xyz.y, scale: editingParam(\.y).scale, isSnappingEnabled: editingParam(\.y).isSnapping, formatter: component.scaleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .z:
                FloatSelector(value: $component.scale.xyz.z, scale: editingParam(\.z).scale, isSnappingEnabled: editingParam(\.z).isSnapping, formatter: component.scaleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
    func editingParam(_ keyPath: KeyPath<simd_float3, Float>) -> Binding<ObjectPropertyFloatEditingParams> {
        $editingParams[floatPropertyId: (\SPTScale.xyz).appending(path: keyPath), component.object]
    }
    
}
