//
//  ObjectColorAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.22.
//

import SwiftUI
import Combine


class ObjectRGBAColorAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    lazy private(set) var red = AnimatorBindingSetupComponent<ObjectRGBAColorChannelAnimatorBindingComponent>(animatableProperty: .red, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var green = AnimatorBindingSetupComponent<ObjectRGBAColorChannelAnimatorBindingComponent>(animatableProperty: .green, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var blue = AnimatorBindingSetupComponent<ObjectRGBAColorChannelAnimatorBindingComponent>(animatableProperty: .blue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Color"
    }
    
    override var subcomponents: [Component]? { [red, green, blue] }
    
}

class ObjectHSBAColorAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    lazy private(set) var hue = AnimatorBindingSetupComponent<ObjectHSBAColorChannelAnimatorBindingComponent>(animatableProperty: .hue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var saturation = AnimatorBindingSetupComponent<ObjectHSBAColorChannelAnimatorBindingComponent>(animatableProperty: .saturation, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var brightness = AnimatorBindingSetupComponent<ObjectHSBAColorChannelAnimatorBindingComponent>(animatableProperty: .brightness, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Color"
    }
    
    override var subcomponents: [Component]? { [hue, saturation, brightness] }
    
}

class ObjectColorAnimatorBindingComponent<C>: MultiVariantComponent where C: SPTObservableComponent {
    
    private let keyPath: WritableKeyPath<C, SPTColor>
    private let object: SPTObject
    private let sceneViewModel: SceneViewModel
    private var colorModelSubscription: SPTAnySubscription?
    private var variantCancellable: AnyCancellable?
    
    init(keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.keyPath = keyPath
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(parent: parent)
        
        colorModelSubscription = C.onDidChangeSink(object: object) { [unowned self] oldValue in
            let oldColorModel = oldValue[keyPath: keyPath].model
            if oldColorModel != self.colorModel {
                self.setupVariant()
            }
        }
        
        setupVariant()
        
    }
    
    var colorModel: SPTColorModel {
        C.get(object: object)[keyPath: keyPath].model
    }
    
    private func setupVariant() {
        self.variantTag = colorModel.rawValue
        switch colorModel {
        case .RGB:
            activeComponent = ObjectRGBAColorAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .HSB:
            activeComponent = ObjectHSBAColorAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
        }
    }
    
}
