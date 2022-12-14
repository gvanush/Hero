//
//  OrientToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


class OrientToolSelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let rotationFormatter = Formatters.angle
    
    @SPTObservedComponent private var sptOrientation: SPTOrientation
    private var originPointObject: SPTObject
    
    @Published var axis: Axis
    
    fileprivate init(axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.axis = axis
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        SPTTransformationSetParent(originPointObject, object.entity)
        SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
        
        _sptOrientation = SPTObservedComponent(object: object)
        _sptOrientation.publisher = self.objectWillChange
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originPointObject)
    }
    
    var eulerRotation: simd_float3 {
        set { sptOrientation.euler.rotation = SPTVector.degreesToRadians(newValue) }
        get { SPTVector.radiansToDegrees(sptOrientation.euler.rotation) }
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: OrientToolSelectedObjectViewModel
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.eulerRotation[model.axis.rawValue], scale: $editingParams[rotationOf: model.object, axis: model.axis].scale, isSnappingEnabled: $editingParams[rotationOf: model.object, axis: model.axis].isSnapping, formatter: model.rotationFormatter) { editingState in
                userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
            }
            .tint(Color.primarySelectionColor)
            .transition(.identity)
            .id(model.axis.rawValue)
            PropertySelector(selected: $model.axis)
        }
    }
    
}

class OrientToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: OrientToolSelectedObjectViewModel?
    
    private var axis = Axis.x
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .orient, sceneViewModel: sceneViewModel)
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


struct OrientToolView: View {
    
    @ObservedObject var model: OrientToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
