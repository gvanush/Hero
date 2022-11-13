//
//  AnimateShadeToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.11.22.
//

import SwiftUI
import Combine


class AnimateShadeToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<MeshLookAnimatorBindingsComponent> {
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: AnimateShadeToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: MeshObjectComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
    }
    
}


class AnimateShadeToolViewModel: ToolViewModel {
    
    typealias EditingParams = AnimateShadeToolSelectedObjectViewModel.EditingParams
    
    @Published private(set) var selectedObjectViewModel: AnimateShadeToolSelectedObjectViewModel?
    
    private var lastActiveComponentPath = ComponentPath()
    private var lastSelectedPropertyIndex: Int?
    private var editingParams = [SPTObject : EditingParams]()
    private var selectedObjectSubscription: AnyCancellable?
    private var activeComponentSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        
        super.init(tool: .animateShade, sceneViewModel: sceneViewModel)
        
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
            editingParams[selectedVM.object] = selectedVM.editingParams
        }
        
        if let object = object {
            selectedObjectViewModel = .init(editingParams: editingParams[object, default: .init()], selectedPropertyIndex: lastSelectedPropertyIndex, activeComponentPath: lastActiveComponentPath, object: object, sceneViewModel: sceneViewModel)
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
            editingParams[duplicate] = selectedObjectVM.editingParams
        } else {
            editingParams[duplicate] = editingParams[original]
        }
    }
    
    override func onObjectDestroy(_ object: SPTObject) {
        editingParams.removeValue(forKey: object)
    }
    
}

struct AnimateShadeToolView: View {
    @ObservedObject var model: AnimateShadeToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
