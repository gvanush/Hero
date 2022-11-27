//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


class MoveToolComponentViewProvider: MeshObjectComponentViewProvider<PositionComponent> {
    
    override func viewForRoot(_ root: PositionComponent) -> AnyView? {
        AnyView(PositionComponentView(component: root, viewProvider: self))
    }
    
}

class MoveToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<PositionComponent> {
}

fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: MoveToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: MoveToolComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
    }
    
}

class MoveToolViewModel: ToolViewModel {
    
    @Published private(set) var selectedObjectViewModel: MoveToolSelectedObjectViewModel?
    
    private var lastActiveComponentPath = ComponentPath()
    private var lastSelectedPropertyIndex: Int?
    private var selectedObjectSubscription: AnyCancellable?
    private var activeComponentSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .move, sceneViewModel: sceneViewModel)
        
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [unowned self] selected in
            guard self.selectedObjectViewModel?.object != selected else { return }
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
        }
        
        if let object = object {
            selectedObjectViewModel = .init(selectedPropertyIndex: lastSelectedPropertyIndex, activeComponentPath: lastActiveComponentPath, object: object, sceneViewModel: sceneViewModel)
            activeComponentSubscription = selectedObjectViewModel!.$activeComponent.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        } else {
            selectedObjectViewModel = nil
            activeComponentSubscription = nil
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
