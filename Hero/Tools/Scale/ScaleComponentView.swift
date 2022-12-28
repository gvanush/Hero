//
//  ScaleComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.12.22.
//

import SwiftUI
import Combine


class ScaleComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel

    private var variantCancellable: AnyCancellable?
    private var originPointObject: SPTObject
    private var scaleSubscription: SPTAnySubscription?
    
    @SPTObservedComponent private var scale: SPTScale
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        
        _scale = .init(object: object)
        
        super.init(parent: parent)
        
        _scale.publisher = self.objectWillChange
        
        SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
        
        scaleSubscription = SPTScale.onDidChangeSink(object: object) { [unowned self] oldValue in
            if oldValue.model != scaleModel {
                self.setupVariant()
            }
        }
        
        setupVariant()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originPointObject)
    }
    
    var scaleModel: SPTScaleModel {
        get {
            scale.model
        }
        set {
            
            guard scaleModel != newValue else {
                return
            }
            
            switch newValue {
            case .XYZ:
                scale = .init(x: scale.uniform, y: scale.uniform, z: scale.uniform)
            case .uniform:
                scale = .init(uniform: scale.xyz.minComponent)
            }
        }
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: originPointObject)
    }
    
    override var title: String {
        "Scale"
    }
    
    private func setupVariant() {
        self.variantTag = scaleModel.rawValue
        switch scaleModel {
        case .XYZ:
            activeComponent = XYZScaleComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .uniform:
            activeComponent = UniformScaleComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
}


struct ScaleComponentView<RC>: View {
    
    @ObservedObject var component: ScaleComponent
    let viewProvider: ComponentViewProvider<RC>
    
    @EnvironmentObject var actionBarModel: ActionBarModel
    
    var body: some View {
        component.activeComponent.accept(viewProvider)
            .actionBarObjectSection {
                ActionBarMenu(title: "Scale Model", iconName: "slider.horizontal.3", selected: $component.scaleModel)
                    .tag(component.id)
            }
            .onAppear {
                actionBarModel.scrollToObjectSection()
            }
    }
    
}
