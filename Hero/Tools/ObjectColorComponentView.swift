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
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .red:
                RGBColorSelector(rgbaColor: $component.color, channel: .red) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
            case .green:
                RGBColorSelector(rgbaColor: $component.color, channel: .green) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
            case .blue:
                RGBColorSelector(rgbaColor: $component.color, channel: .blue) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
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
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .hue:
                HSBColorSelector(hsbaColor: $component.color, channel: .hue) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
            case .saturation:
                HSBColorSelector(hsbaColor: $component.color, channel: .saturation) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
            case .brightness:
                HSBColorSelector(hsbaColor: $component.color, channel: .brightness) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
            case .none:
                EmptyView()
            }
        }
        .tint(.primarySelectionColor)
        .transition(.identity)
    }
}

class ObjectColorComponent<C>: MultiVariantComponent where C: SPTObservableComponent {
    
    private let keyPath: WritableKeyPath<C, SPTColor>
    private let object: SPTObject
    private var componentSubscription: SPTAnySubscription?
    private var variantCancellable: AnyCancellable?
    
    init(keyPath: WritableKeyPath<C, SPTColor>, object: SPTObject, parent: Component?) {
        
        self.keyPath = keyPath
        self.object = object
        
        super.init(parent: parent)
        
        componentSubscription = C.onDidChangeSink(object: object) { [unowned self] oldValue in
            let oldColorModel = oldValue[keyPath: keyPath].model
            if oldColorModel != self.colorModel {
                self.setupVariant()
            }
        }
        
        setupVariant()
        
    }
    
    var colorModel: SPTColorModel {
        get {
            C.get(object: object)[keyPath: keyPath].model
        }
        set {
            var component = C.get(object: object)
            
            let color = component[keyPath: keyPath]
            switch newValue {
            case .RGB:
                component[keyPath: keyPath] = color.toRGBA
            case .HSB:
                component[keyPath: keyPath] = color.toHSBA
            }
            
            C.update(component, object: object)
        }
    }
    
    private func setupVariant() {
        switch colorModel {
        case .RGB:
            activeComponent = ObjectRGBAColorComponent(keyPath: keyPath.appending(path: \.rgba), object: object, parent: parent)
        case .HSB:
            activeComponent = ObjectHSBAColorComponent(keyPath: keyPath.appending(path: \.hsba), object: object, parent: parent)
        }
        activeComponent.variantTag = colorModel.rawValue
        variantCancellable = activeComponent.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
 
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
}

struct ObjectColorComponentView<C, RC>: View where C: SPTObservableComponent {
    
    @ObservedObject var component: ObjectColorComponent<C>
    let viewProvider: ComponentViewProvider<RC>
    
    @EnvironmentObject var actionBarModel: ActionBarModel
    
    var body: some View {
        component.activeComponent.accept(viewProvider)
            .actionBarObjectSection {
                ActionBarMenu(iconName: "slider.vertical.3", selected: $component.colorModel)
                    .tag(component.id)
            }
            .onAppear {
                actionBarModel.scrollToObjectSection()
            }
    }
    
}
