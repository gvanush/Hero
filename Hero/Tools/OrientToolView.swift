//
//  OrientToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


fileprivate class SelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @SPTObservedComponent private var sptOrientation: SPTOrientation
    private var guideObject: SPTObject?
    
    init(object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _sptOrientation = SPTObservedComponent(object: object)
        _sptOrientation.publisher = self.objectWillChange
    }
    
    var eulerRotation: simd_float3 {
        set { sptOrientation.euler.rotation = SPTToRadFloat3(newValue) }
        get { SPTToDegFloat3(sptOrientation.euler.rotation) }
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
    @State private var scale = FloatSelector.Scale._10
    @State private var isSnappingEnabled = false
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.eulerRotation[axis.rawValue], scale: $scale, isSnappingEnabled: $isSnappingEnabled, measurementFormatter: .angleFormatter, formatterSubjectProvider: MeasurementFormatter.angleSubjectProvider)
                .selectedObjectUI(cornerRadius: FloatSelector.cornerRadius)
                .transition(.identity)
                .id(axis.rawValue)
                .id(model.object)
            Selector(selected: $axis)
                .selectedObjectUI(cornerRadius: SelectorConst.cornerRadius)
        }
        .onChange(of: axis, perform: { newValue in
//            model.removeGuideObjects()
//            model.setupGuideObjects(axis: newValue)
        })
        .onAppear {
//            model.setupGuideObjects(axis: axis)
        }
        .onDisappear {
//            model.removeGuideObjects()
        }
    }
    
}

class OrientToolViewModel: ToolViewModel {
    
    fileprivate var selectedObjectViewModel: SelectedObjectViewModel?
    
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .orient, sceneViewModel: sceneViewModel)
        
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


struct OrientToolView: View {
    
    @ObservedObject var model: OrientToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
        } else {
            EmptyView()
        }
    }
}
