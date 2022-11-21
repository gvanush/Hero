//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


class MoveToolSelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let positionFormatter = Formatters.positionField
    
    @Published var axis: Axis {
        didSet {
            removeGuideObjects()
            setupGuideObjects()
        }
    }
    
    @SPTObservedComponent private var sptPosition: SPTPosition
    private var guideObject: SPTObject?
    
    fileprivate init(axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.axis = axis
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _sptPosition = SPTObservedComponent(object: object)
        _sptPosition.publisher = self.objectWillChange
    }
    
    var position: simd_float3 {
        set { sptPosition.xyz = newValue }
        get { sptPosition.xyz }
    }
    
    func setupGuideObjects() {
        assert(guideObject == nil)

        let object = sceneViewModel.scene.makeObject()
        SPTScaleMake(object, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTPolylineLookDepthBiasMake(object, 5.0, 3.0, 0.0)

        switch axis {
        case .x:
            SPTPosition.make(.init(x: 0.0, y: position.y, z: position.z), object: object)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: object)
            
        case .y:
            SPTPosition.make(.init(x: position.x, y: 0.0, z: position.z), object: object)
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ)), object: object)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: object)
            
        case .z:
            SPTPosition.make(.init(x: position.x, y: position.y, z: 0.0), object: object)
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: object)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: object)
        }

        guideObject = object
    }
    
    func removeGuideObjects() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: MoveToolSelectedObjectViewModel
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.position[model.axis.rawValue], scale: $editingParams[positionOf: model.object, axis: model.axis].scale, isSnappingEnabled: $editingParams[positionOf: model.object, axis: model.axis].isSnapping, formatter: model.positionFormatter) { editingState in
                userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
            }
            .tint(Color.primarySelectionColor)
            .transition(.identity)
            .id(model.axis.rawValue)
            PropertySelector(selected: $model.axis)
        }
        .onAppear {
            model.setupGuideObjects()
        }
        .onDisappear {
            model.removeGuideObjects()
        }
    }
    
}

class MoveToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: MoveToolSelectedObjectViewModel?
    
    private var axis = Axis.x
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .move, sceneViewModel: sceneViewModel)
        
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            guard let self = self, self.selectedObjectViewModel?.object != selected else { return }
            self.setupSelectedObjectViewModel(object: selected)
        }
        
        setupSelectedObjectViewModel(object: sceneViewModel.selectedObject)
        
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


struct MoveToolView: View {
    
    @ObservedObject var model: MoveToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
