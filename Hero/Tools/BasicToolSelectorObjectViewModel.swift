//
//  BasicToolSelectorObjectViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import Foundation
import Combine


struct BasicToolComponentRecord: Hashable {
    let indexPath: IndexPath
    let variantTags: [UInt32]
    
    init(indexPath: IndexPath, variantTags: [UInt32]) {
        guard variantTags.count - indexPath.count == 1 else {
            fatalError()
        }
        self.indexPath = indexPath
        self.variantTags = variantTags
    }
    
    init() {
        self.init(indexPath: .init(), variantTags: [0])
    }
}

struct BasicToolObjectEditingParams {
    var activeComponentRecord = BasicToolComponentRecord()
    var selectedPropertyIndices = [BasicToolComponentRecord : Int?]()
}

protocol BasicToolSelectedObjectRootComponent where Self: Component {
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?)
    
}

class BasicToolSelectedObjectViewModel<RC>: ObservableObject where RC: BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let rootComponent: RC
    @Published var activeComponent: Component!
    
    init(editingParams: BasicToolObjectEditingParams?, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        self.rootComponent = RC(object: object, sceneViewModel: sceneViewModel, parent: nil)
        if let editingParams = editingParams {
            self.activeComponent = determineActiveComponent(component: rootComponent, record: editingParams.activeComponentRecord, index: 0)
            applySelectedPropertyIndices(editingParams: editingParams, component: rootComponent, indexPath: .init(), variantTags: [])
        } else {
            self.activeComponent = rootComponent
        }
    }
    
    func determineActiveComponent(component: Component, record: BasicToolComponentRecord, index: Int) -> Component {
        
        if component.variantTag != record.variantTags[index] || index >= record.indexPath.count {
            var firstSetup = component
            while !firstSetup.isSetup {
                firstSetup = firstSetup.parent!
            }
            return firstSetup
        }
        
        let subIndex = record.indexPath[index]
        
        return determineActiveComponent(component: component.subcomponents![subIndex], record: record, index: index + 1)
        
    }
    
    func applySelectedPropertyIndices(editingParams: BasicToolObjectEditingParams, component: Component, indexPath: IndexPath, variantTags: [UInt32]) {
        
        var variantTags = variantTags
        variantTags.append(component.variantTag)
        let record = BasicToolComponentRecord(indexPath: indexPath, variantTags: variantTags)
        
        if let selectedPropertyIndex = editingParams.selectedPropertyIndices[record] {
            component.selectedPropertyIndex = selectedPropertyIndex
        }
        
        if let subs = component.subcomponents {
            for (index, sub) in subs.enumerated() {
                applySelectedPropertyIndices(editingParams: editingParams, component: sub, indexPath: indexPath.appending(index), variantTags: variantTags)
            }
        }
    }
}


class BasicToolViewModel<SVM, RC>: ToolViewModel where SVM: BasicToolSelectedObjectViewModel<RC> {
    
    @Published private(set) var selectedObjectViewModel: SVM?
    
    private var editingParams = [SPTObject : BasicToolObjectEditingParams]()
    private var selectedObjectSubscription: AnyCancellable?
    private var activeComponentSubscription: AnyCancellable?
    
    override init(tool: Tool, sceneViewModel: SceneViewModel) {
        super.init(tool: tool, sceneViewModel: sceneViewModel)
    }
    
    override func onActive() {
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [unowned self] selected in
            guard self.selectedObjectViewModel?.object != selected else { return }
            self.setupSelectedObjectViewModel(object: selected)
        }
    }
    
    override func onInactive() {
        selectedObjectSubscription = nil
        setupSelectedObjectViewModel(object: nil)
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
            saveEditingParams(selectedObjectViewModel: selectedVM)
        }
        
        if let object = object {
            selectedObjectViewModel = .init(editingParams: editingParams[object], object: object, sceneViewModel: sceneViewModel)
            activeComponentSubscription = selectedObjectViewModel!.$activeComponent.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        } else {
            selectedObjectViewModel = nil
            activeComponentSubscription = nil
        }
    }
    
    private func saveEditingParams(selectedObjectViewModel: SVM) {
        let activeIndexPath = selectedObjectViewModel.activeComponent.indexPathIn(selectedObjectViewModel.rootComponent)!
        var variantTags = [UInt32]()
        getVariantTags(component: selectedObjectViewModel.activeComponent, &variantTags)
        
        editingParams[selectedObjectViewModel.object, default: .init()].activeComponentRecord = .init(indexPath: activeIndexPath, variantTags: variantTags)
        saveSelectedPropertyIndices(object: selectedObjectViewModel.object, component: selectedObjectViewModel.rootComponent, indexPath: .init(), variantTags: [])
    }
    
    private func saveSelectedPropertyIndices(object: SPTObject, component: Component, indexPath: IndexPath, variantTags: [UInt32]) {
        
        var variantTags = variantTags
        variantTags.append(component.variantTag)
        
        let record = BasicToolComponentRecord(indexPath: indexPath, variantTags: variantTags)
        
        editingParams[object, default: .init()].selectedPropertyIndices[record] = component.selectedPropertyIndex
        
        if let subs = component.subcomponents {
            for (index, sub) in subs.enumerated() {
                saveSelectedPropertyIndices(object: object, component: sub, indexPath: indexPath.appending(index), variantTags: variantTags)
            }
        }
    }
    
    private func getVariantTags(component: Component, _ variantTags: inout [UInt32]) {
        
        variantTags.append(component.variantTag)
        
        if let parent = component.parent {
            getVariantTags(component: parent, &variantTags)
        }
        
    }
    
    override func onObjectDuplicate(original: SPTObject, duplicate: SPTObject) {
        if let selectedVM = selectedObjectViewModel, selectedVM.object == original {
            saveEditingParams(selectedObjectViewModel: selectedVM)
        }
        editingParams[duplicate] = editingParams[original]
    }
    
    override func onObjectDestroy(_ object: SPTObject) {
        editingParams.removeValue(forKey: object)
    }
    
}
