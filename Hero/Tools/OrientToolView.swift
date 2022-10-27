//
//  OrientToolView.swift
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

class OrientToolSelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let rotationFormatter = AngleFormatter()
    
    @SPTObservedComponent private var sptOrientation: SPTOrientation
    private var guideObject: SPTObject?
    
    @Published var axis: Axis
    
    @Published fileprivate var propertyEditingParams: PropertyEditingParams
    
    fileprivate init(axis: Axis, propertyEditingParams: PropertyEditingParams, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.axis = axis
        self.propertyEditingParams = propertyEditingParams
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _sptOrientation = SPTObservedComponent(object: object)
        _sptOrientation.publisher = self.objectWillChange
    }
    
    var eulerRotation: simd_float3 {
        set { sptOrientation.euler.rotation = SPTToRadFloat3(newValue) }
        get { SPTToDegFloat3(sptOrientation.euler.rotation) }
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
    
    @ObservedObject var model: OrientToolSelectedObjectViewModel
    
    var body: some View {
        VStack {
            FloatSelector(value: $model.eulerRotation[model.axis.rawValue], scale: $model.editingParam.scale, isSnappingEnabled: $model.editingParam.isSnapping, formatter: model.rotationFormatter)
                .tint(Color.objectSelectionColor)
                .transition(.identity)
                .id(model.axis.rawValue)
            PropertySelector(selected: $model.axis)
        }
    }
    
}

class OrientToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: OrientToolSelectedObjectViewModel?
    
    private var axis = Axis.x
    private var propertyEditingParams = [SPTObject : PropertyEditingParams]()
    private var selectedObjectSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .orient, sceneViewModel: sceneViewModel)
        
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


struct OrientToolView: View {
    
    @ObservedObject var model: OrientToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
