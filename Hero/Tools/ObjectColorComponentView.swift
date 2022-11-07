//
//  ObjectColorComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import SwiftUI
import Combine


class ObjectRGBAColorComponent<C>: BasicComponent<RGBColorChannel> where C: SPTObservableComponent {

    @SPTObservedComponentProperty<C, SPTRGBAColor> var color: SPTRGBAColor

    init(keyPath: WritableKeyPath<C, SPTRGBAColor>, object: SPTObject, parent: Component?) {
        
        _color = .init(object: object, keyPath: keyPath)
        
        super.init(selectedProperty: .red, parent: parent)
        
        _color.publisher = self.objectWillChange
        
    }
    
    override var title: String {
        "Color"
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}

struct ObjectRGBAColorComponentView<C>: View where C: SPTObservableComponent {
    
    @ObservedObject var component: ObjectRGBAColorComponent<C>
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .red:
                RGBColorSelector(rgbaColor: $component.color, channel: .red)
            case .green:
                RGBColorSelector(rgbaColor: $component.color, channel: .green)
            case .blue:
                RGBColorSelector(rgbaColor: $component.color, channel: .blue)
            case .none:
                EmptyView()
            }
        }
        .tint(.primarySelectionColor)
        .transition(.identity)
    }
}

class ObjectHSBAColorComponent<C>: BasicComponent<HSBColorChannel> where C: SPTObservableComponent {

    @SPTObservedComponentProperty<C, SPTHSBAColor> var color: SPTHSBAColor

    init(keyPath: WritableKeyPath<C, SPTHSBAColor>, object: SPTObject, parent: Component?) {
        
        _color = .init(object: object, keyPath: keyPath)
        
        super.init(selectedProperty: .hue, parent: parent)
        
        _color.publisher = self.objectWillChange
        
    }
    
    override var title: String {
        "Color"
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}

struct ObjectHSBAColorComponentView<C>: View where C: SPTObservableComponent {
    
    @ObservedObject var component: ObjectHSBAColorComponent<C>
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .hue:
                HSBColorSelector(hsbaColor: $component.color, channel: .hue)
            case .saturation:
                HSBColorSelector(hsbaColor: $component.color, channel: .saturation)
            case .brightness:
                HSBColorSelector(hsbaColor: $component.color, channel: .brightness)
            case .none:
                EmptyView()
            }
        }
        .tint(.primarySelectionColor)
        .transition(.identity)
    }
}

class ObjectColorComponent<C>: Component where C: SPTObservableComponent {
    
    struct EditingParams {
    }
    
    @Published var editingParams: EditingParams
    @Published var activeComponent: Component!
    
    private var colorModelSubscription: SPTAnySubscription?
    private var variantCancellable: AnyCancellable?
    
    init(editingParams: EditingParams, keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject, parent: Component?) {
        
        self.editingParams = editingParams
        
        super.init(parent: parent)
        
        let colorModel = {
            C.get(object: object)[keyPath: keyPath].model
        }
        
        colorModelSubscription = C.onWillChangeSink(object: object) { [weak self] newColor in
            let newColorModel = newColor[keyPath: keyPath].model
            if newColorModel != colorModel() {
                self?.setupVariant(colorModel: newColorModel, keyPath: keyPath, object: object)
            }
        }
        
        setupVariant(colorModel: colorModel(), keyPath: keyPath, object: object)
        
        // TODO
        self.actions.append(.init(iconName: "camera.filters", action: {
            
            var component = C.get(object: object)
            
            let color = component[keyPath: keyPath]
            switch color.model {
            case .RGB:
                component[keyPath: keyPath] = color.toHSBA
            case .HSB:
                component[keyPath: keyPath] = color.toRGBA
            }
            
            C.update(component, object: object)
        }))
        
    }
    
    private func setupVariant(colorModel: SPTColorModel, keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject) {
        switch colorModel {
        case .RGB:
            activeComponent = ObjectRGBAColorComponent(keyPath: keyPath.appending(path: \.rgba), object: object, parent: parent)
        case .HSB:
            activeComponent = ObjectHSBAColorComponent(keyPath: keyPath.appending(path: \.hsba), object: object, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    override var title: String {
        activeComponent.title
    }
    
    override var properties: [String]? {
        activeComponent.properties
    }
    
    override var selectedPropertyIndex: Int? {
        get {
            activeComponent.selectedPropertyIndex
        }
        set {
            activeComponent.selectedPropertyIndex = newValue
        }
    }
    
    override var subcomponents: [Component]? {
        activeComponent.subcomponents
    }
 
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        activeComponent.accept(provider)
    }
}
