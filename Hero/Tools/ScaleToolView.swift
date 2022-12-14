//
//  ScaleToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


class ScaleToolSelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let scaleFormatter = Formatters.scaleField
    
    @SPTObservedComponent private var sptScale: SPTScale
    private var originPointObject: SPTObject
    
    @Published var axis: Axis
    
    fileprivate init(axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.axis = axis
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
        SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
        
        _sptScale = SPTObservedComponent(object: object)
        _sptScale.publisher = self.objectWillChange
        
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originPointObject)
    }
    
    var scale: simd_float3 {
        set { sptScale.xyz = newValue }
        get { sptScale.xyz }
    }
 
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: ScaleToolSelectedObjectViewModel
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.scale[model.axis.rawValue], scale: $editingParams[scaleOf: model.object, axis: model.axis].scale, isSnappingEnabled: $editingParams[scaleOf: model.object, axis: model.axis].isSnapping, formatter: model.scaleFormatter) { editingState in
                userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
            }
            .tint(Color.primarySelectionColor)
            .transition(.identity)
            .id(model.axis.rawValue)
            PropertySelector(selected: $model.axis)
        }
    }
    
}

class ScaleToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: ScaleToolSelectedObjectViewModel?
    
    private var axis = Axis.x
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .scale, sceneViewModel: sceneViewModel)
    }
    
    override func onActive() {
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            guard let self = self, self.selectedObjectViewModel?.object != selected else { return }
            self.setupSelectedObjectViewModel(object: selected)
        }
    }
    
    override func onInactive() {
        selectedObjectSubscription = nil
        setupSelectedObjectViewModel(object: nil)
    }
    
    private func setupSelectedObjectViewModel(object: SPTObject?) {
        
        if let selectedVM = selectedObjectViewModel {
            axis = selectedVM.axis
        }
        
        if let object = object {
            selectedObjectViewModel = .init(axis: axis, object: object, sceneViewModel: sceneViewModel)
        } else {
            selectedObjectViewModel = nil
        }
    }
    
}


struct ScaleToolView: View {
    @ObservedObject var model: ScaleToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
