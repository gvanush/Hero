//
//  ObjectColorAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.22.
//

import SwiftUI
import Combine


class ObjectRGBAColorAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    struct EditingParams {
        var red = ObjectRGBAColorChannelAnimatorBindingComponent.EditingParams()
        var green = ObjectRGBAColorChannelAnimatorBindingComponent.EditingParams()
        var blue = ObjectRGBAColorChannelAnimatorBindingComponent.EditingParams()
    }
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    private let initialEditingParams: EditingParams
    
    lazy private(set) var red = AnimatorBindingSetupComponent<ObjectRGBAColorChannelAnimatorBindingComponent>(initialEditingParams: initialEditingParams.red, animatableProperty: .red, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var green = AnimatorBindingSetupComponent<ObjectRGBAColorChannelAnimatorBindingComponent>(initialEditingParams: initialEditingParams.green, animatableProperty: .green, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var blue = AnimatorBindingSetupComponent<ObjectRGBAColorChannelAnimatorBindingComponent>(initialEditingParams: initialEditingParams.blue, animatableProperty: .blue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(editingParams: EditingParams, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        self.initialEditingParams = editingParams
        super.init(parent: parent)
    }
    
    override var title: String {
        "Color"
    }
    
    override var subcomponents: [Component]? { [red, green, blue] }
    
    var editingParams: EditingParams {
        .init(red: red.editingParams, green: green.editingParams, blue: blue.editingParams)
    }
    
}

class ObjectHSBAColorAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    struct EditingParams {
        var hue = ObjectHSBAColorChannelAnimatorBindingComponent.EditingParams()
        var saturation = ObjectHSBAColorChannelAnimatorBindingComponent.EditingParams()
        var brightness = ObjectHSBAColorChannelAnimatorBindingComponent.EditingParams()
    }
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    private let initialEditingParams: EditingParams
    
    lazy private(set) var hue = AnimatorBindingSetupComponent<ObjectHSBAColorChannelAnimatorBindingComponent>(initialEditingParams: initialEditingParams.hue, animatableProperty: .hue, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var saturation = AnimatorBindingSetupComponent<ObjectHSBAColorChannelAnimatorBindingComponent>(initialEditingParams: initialEditingParams.saturation, animatableProperty: .saturation, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var brightness = AnimatorBindingSetupComponent<ObjectHSBAColorChannelAnimatorBindingComponent>(initialEditingParams: initialEditingParams.brightness, animatableProperty: .brightness, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(editingParams: EditingParams, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        self.initialEditingParams = editingParams
        super.init(parent: parent)
    }
    
    override var title: String {
        "Color"
    }
    
    override var subcomponents: [Component]? { [hue, saturation, brightness] }
    
    var editingParams: EditingParams {
        .init(hue: hue.editingParams, saturation: saturation.editingParams, brightness: brightness.editingParams)
    }
    
}

class ObjectColorAnimatorBindingComponent<C>: MultiVariantComponent where C: SPTObservableComponent {
    
    struct EditingParams {
    }
    
    @Published var editingParams: EditingParams
    
    private let keyPath: WritableKeyPath<C, SPTColor>
    private let object: SPTObject
    private let sceneViewModel: SceneViewModel
    private var colorModelSubscription: SPTAnySubscription?
    private var variantCancellable: AnyCancellable?
    
    init(editingParams: EditingParams, keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.editingParams = editingParams
        self.keyPath = keyPath
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(parent: parent)
        
        colorModelSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            let newColorModel = newValue[keyPath: keyPath].model
            if newColorModel != self!.colorModel {
                self?.setupVariant(colorModel: newColorModel, keyPath: keyPath, object: object)
            }
        }
        
        setupVariant(colorModel: colorModel, keyPath: keyPath, object: object)
        
    }
    
    var colorModel: SPTColorModel {
        C.get(object: object)[keyPath: keyPath].model
    }
    
    private func setupVariant(colorModel: SPTColorModel, keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject) {
        switch colorModel {
        case .RGB:
            activeComponent = ObjectRGBAColorAnimatorBindingsComponent(editingParams: .init(), object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .HSB:
            activeComponent = ObjectHSBAColorAnimatorBindingsComponent(editingParams: .init(), object: object, sceneViewModel: sceneViewModel, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
}
