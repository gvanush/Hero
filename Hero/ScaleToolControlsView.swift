//
//  ScaleToolControlsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


fileprivate class SelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @SPTObservedComponent private var sptScale: SPTScale
    private var guideObject: SPTObject?
    
    init(object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _sptScale = SPTObservedComponent(object: object)
        _sptScale.publisher = self.objectWillChange
    }
    
    var scale: simd_float3 {
        set { sptScale.xyz = newValue }
        get { sptScale.xyz }
    }
    
    func setupGuideObjects(axis: Axis) {
        assert(guideObject == nil)

        let guideObject = sceneViewModel.scene.makeObject()
        SPTScaleMake(guideObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTPolylineLookDepthBiasMake(guideObject, 5.0, 3.0, 0.0)

        let position = SPTPosition.get(object: object).xyz
        
        switch axis {
        case .x:
            SPTPosition.make(.init(x: 0.0, y: position.y, z: position.z), object: guideObject)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: guideObject)
            
        case .y:
            SPTPosition.make(.init(x: position.x, y: 0.0, z: position.z), object: guideObject)
            SPTOrientationMakeEuler(guideObject, .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ))
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: guideObject)
            
        case .z:
            SPTPosition.make(.init(x: position.x, y: position.y, z: 0.0), object: guideObject)
            SPTOrientationMakeEuler(guideObject, .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ))
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: guideObject)
        }

        self.guideObject = guideObject
    }
    
    func removeGuideObjects() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: SelectedObjectViewModel
    
    @State private var axis = Axis.x
    @State private var scale = FloatSelector.Scale._0_1
    @State private var isSnappingEnabled = false
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.scale[axis.rawValue], scale: $scale, isSnappingEnabled: $isSnappingEnabled)
                .selectedObjectUI(cornerRadius: FloatSelector.cornerRadius)
                .transition(.identity)
                .id(axis.rawValue)
            Selector(selected: $axis)
                .selectedObjectUI(cornerRadius: SelectorConst.cornerRadius)
        }
        .onChange(of: axis, perform: { newValue in
            model.removeGuideObjects()
            model.setupGuideObjects(axis: newValue)
        })
        .onAppear {
            model.setupGuideObjects(axis: axis)
        }
        .onDisappear {
            model.removeGuideObjects()
        }
    }
    
}

class ScaleToolViewModel: ObservableObject {
    
    let sceneViewModel: SceneViewModel
    
    fileprivate var selectedObjectViewModel: SelectedObjectViewModel?
    
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        self.sceneViewModel = sceneViewModel
        
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            self?.setupSelectedObjectViewModel(object: selected)
        }
        
        setupSelectedObjectViewModel(object: sceneViewModel.selectedObject)
        
    }
    
    private func setupSelectedObjectViewModel(object: SPTObject?) {
        if let object = object {
            selectedObjectViewModel = .init(object: object, sceneViewModel: sceneViewModel)
        } else {
            selectedObjectViewModel = nil
        }
    }
    
}


struct ScaleToolControlsView: View {
    @StateObject var model: ScaleToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
        } else {
            EmptyView()
        }
    }
}
