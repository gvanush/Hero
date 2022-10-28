//
//  AnimatePositionToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.10.22.
//

import SwiftUI
import Combine

fileprivate typealias EditingParams = PositionAnimatorBindingsComponent.EditingParams

class AnimatePositionToolSelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let rootComponent: PositionAnimatorBindingsComponent
    @Published var activeComponent: Component
    
    fileprivate init(editingParams: EditingParams, selectedPropertyIndex: Int?, activeComponentPath: ComponentPath, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        self.rootComponent = PositionAnimatorBindingsComponent(editingParams: editingParams, object: object, sceneViewModel: sceneViewModel, parent: nil)
        
        var activeComponent = rootComponent.componentAt(activeComponentPath)
        while let component = activeComponent, !component.isSetup {
            activeComponent = component.parent
        }
        
        self.activeComponent = activeComponent ?? rootComponent
        self.activeComponent.selectedPropertyIndex = selectedPropertyIndex
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: AnimatePositionToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: MeshObjectComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
    }
    
}


class AnimatePositionToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: AnimatePositionToolSelectedObjectViewModel?
    
    private var lastActiveComponentPath = ComponentPath()
    private var lastSelectedPropertyIndex: Int?
    private var propertyEditingParams = [SPTObject : EditingParams]()
    private var selectedObjectSubscription: AnyCancellable?
    private var activeComponentSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        
        super.init(tool: .animatePosition, sceneViewModel: sceneViewModel)
        
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            guard let self = self, self.selectedObjectViewModel?.object != selected else { return }
            self.setupSelectedObjectViewModel(object: selected)
        }
        
        setupSelectedObjectViewModel(object: sceneViewModel.selectedObject)
        
    }
    
    override var activeComponent: Component? {
        set {
            guard let selectedObjectViewModel = selectedObjectViewModel else {
                return
            }
            selectedObjectViewModel.activeComponent = newValue ?? selectedObjectViewModel.rootComponent
        }
        get {
            selectedObjectViewModel?.activeComponent
        }
    }
    
    private func setupSelectedObjectViewModel(object: SPTObject?) {
        
        if let selectedVM = selectedObjectViewModel {
            lastActiveComponentPath = selectedVM.activeComponent.pathIn(selectedVM.rootComponent)!
            lastSelectedPropertyIndex = selectedVM.activeComponent.selectedPropertyIndex
            propertyEditingParams[selectedVM.object] = selectedVM.rootComponent.editingParams
        }
        
        if let object = object {
            selectedObjectViewModel = .init(editingParams: propertyEditingParams[object, default: .init()], selectedPropertyIndex: lastSelectedPropertyIndex, activeComponentPath: lastActiveComponentPath, object: object, sceneViewModel: sceneViewModel)
            activeComponentSubscription = selectedObjectViewModel!.$activeComponent.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        } else {
            selectedObjectViewModel = nil
            activeComponentSubscription = nil
        }
    }
    
    override func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
        if let selectedObjectVM = selectedObjectViewModel, original == selectedObjectVM.object {
            propertyEditingParams[duplicate] = selectedObjectVM.rootComponent.editingParams
        } else {
            propertyEditingParams[duplicate] = propertyEditingParams[original]
        }
    }
    
    override func onObjectDestroy(_ object: SPTObject) {
        propertyEditingParams.removeValue(forKey: object)
    }
    
}


struct AnimatePositionToolView: View {
    
    @ObservedObject var model: AnimatePositionToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
