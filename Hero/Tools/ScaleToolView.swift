//
//  ScaleToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine

fileprivate struct PropertyEditingParams {
    
    struct Item {
        var scale = FloatSelector.Scale._1
        var isSnapping = false
    }
    
    var x = Item()
    var y = Item()
    var z = Item()
    
    subscript(_ axis: Axis) -> Item {
        set {
            switch axis {
            case .x:
                x = newValue
            case .y:
                y = newValue
            case .z:
                z = newValue
            }
        }
        get {
            switch axis {
            case .x:
                return x
            case .y:
                return y
            case .z:
                return z
            }
        }
    }
    
}

class ScaleToolSelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @SPTObservedComponent private var sptScale: SPTScale
    private var guideObject: SPTObject?
    
    @Published var axis: Axis
    
    @Published fileprivate var propertyEditingParams: PropertyEditingParams
    
    fileprivate init(axis: Axis, propertyEditingParams: PropertyEditingParams, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.axis = axis
        self.propertyEditingParams = propertyEditingParams
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _sptScale = SPTObservedComponent(object: object)
        _sptScale.publisher = self.objectWillChange
    }
    
    var scale: simd_float3 {
        set { sptScale.xyz = newValue }
        get { sptScale.xyz }
    }
 
    fileprivate var editingParam: PropertyEditingParams.Item {
        set {
            propertyEditingParams[axis] = newValue
        }
        get {
            propertyEditingParams[axis]
        }
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: ScaleToolSelectedObjectViewModel
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.scale[model.axis.rawValue], scale: $model.editingParam.scale, isSnappingEnabled: $model.editingParam.isSnapping)
                .tint(Color.objectSelectionColor)
                .transition(.identity)
                .id(model.axis.rawValue)
            PropertySelector(selected: $model.axis)
        }
    }
    
}

class ScaleToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: ScaleToolSelectedObjectViewModel?
    
    private var axis = Axis.x
    private var propertyEditingParams = [SPTObject : PropertyEditingParams]()
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .scale, sceneViewModel: sceneViewModel)
    
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            guard let self = self, self.selectedObjectViewModel?.object != selected else { return }
            self.setupSelectedObjectViewModel(object: selected)
        }
        
        setupSelectedObjectViewModel(object: sceneViewModel.selectedObject)
        
    }
    
    private func setupSelectedObjectViewModel(object: SPTObject?) {
        
        if let selectedVM = selectedObjectViewModel {
            axis = selectedVM.axis
            propertyEditingParams[selectedVM.object] = selectedVM.propertyEditingParams
        }
        
        if let object = object {
            selectedObjectViewModel = .init(axis: axis, propertyEditingParams: propertyEditingParams[object, default: .init()], object: object, sceneViewModel: sceneViewModel)
        } else {
            selectedObjectViewModel = nil
        }
    }
    
    override func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
        if let selectedObjectVM = selectedObjectViewModel, original == selectedObjectVM.object {
            propertyEditingParams[duplicate] = selectedObjectVM.propertyEditingParams
        } else {
            propertyEditingParams[duplicate] = propertyEditingParams[original]
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
