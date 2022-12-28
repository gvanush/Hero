//
//  ScaleComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.12.22.
//

import SwiftUI
import Combine


class ScaleComponent: BasicComponent<Axis>, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let scaleFormatter = Formatters.scale

    private var originPointObject: SPTObject
    private var positionSubscription: SPTAnySubscription?
    private var guideObject: SPTObject?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        
        super.init(selectedProperty: .x, parent: parent)
        
        SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
        positionSubscription = SPTPosition.onWillChangeSink(object: object) { [unowned self] newValue in
            SPTPosition.update(newValue, object: self.originPointObject)
        }
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originPointObject)
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
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: originPointObject)
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
    
    override var title: String {
        "Scale"
    }
    
}


struct ScaleComponentView: View {
    
    @ObservedObject var component: ScaleComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        FloatSelector(value: $component.scale.xyz[component.selectedProperty.rawValue], scale: $editingParams[scaleOf: component.object, axis: component.selectedProperty].scale, isSnappingEnabled: $editingParams[scaleOf: component.object, axis: component.selectedProperty].isSnapping, formatter: component.scaleFormatter) { editingState in
            userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
        .id(component.selectedProperty.rawValue)

    }
    
}
