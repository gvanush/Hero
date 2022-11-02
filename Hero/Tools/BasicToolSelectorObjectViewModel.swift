//
//  BasicToolSelectorObjectViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import Foundation

protocol BasicToolSelectedObjectRootComponent where Self: Component {
    
    associatedtype EditingParams
    
    init(editingParams: EditingParams, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?)
    
    var editingParams: EditingParams { get }
}

class BasicToolSelectedObjectViewModel<RC>: ObservableObject where RC: BasicToolSelectedObjectRootComponent {
    
    typealias EditingParams = RC.EditingParams
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let rootComponent: RC
    @Published var activeComponent: Component
    
    init(editingParams: RC.EditingParams, selectedPropertyIndex: Int?, activeComponentPath: ComponentPath, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        self.rootComponent = RC(editingParams: editingParams, object: object, sceneViewModel: sceneViewModel, parent: nil)
        
        var activeComponent = rootComponent.componentAt(activeComponentPath)
        while let component = activeComponent, !component.isSetup {
            activeComponent = component.parent
        }
        
        self.activeComponent = activeComponent ?? rootComponent
        if let properties = self.activeComponent.properties, !properties.isEmpty {
            self.activeComponent.selectedPropertyIndex = selectedPropertyIndex ?? 0
        }
    }
    
    var editingParams: EditingParams {
        rootComponent.editingParams
    }
    
}
