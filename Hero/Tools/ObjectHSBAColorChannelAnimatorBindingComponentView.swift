//
//  ObjectHSBAColorChannelAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.22.
//

import SwiftUI
import Combine


class ObjectHSBAColorChannelAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var selectedPropertySubscription: AnyCancellable?
    private var channelInitialValue: Float!
    
    @SPTObservedComponentProperty<SPTMeshLook, Float> var channelValue: Float
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        var keyPath: WritableKeyPath<SPTMeshLook, Float>!
        switch animatableProperty {
        case .hue:
            keyPath = \.shading.blinnPhong.color.hsba.hue
        case .saturation:
            keyPath = \.shading.blinnPhong.color.hsba.saturation
        case .brightness:
            keyPath = \.shading.blinnPhong.color.hsba.brightness
        default:
            fatalError()
        }
        
        _channelValue = .init(object: object, keyPath: keyPath)
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        _channelValue.publisher = self.objectWillChange
    }
    
    func onAppear() {
        channelInitialValue = channelValue
        
        selectedPropertySubscription = self.$selectedProperty.sink { [weak self] newValue in
            guard let property = newValue, let self = self else { return }
            self.updateChannelValue(property: property)
        }
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [weak self] newValue in
            guard let self = self, let property = self.selectedProperty else { return }

            self.updateChannelValue(property: property)

        })
    }
    
    func onDisappear() {
        channelValue = channelInitialValue
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    var value0HSBAColor: SPTHSBAColor {
        get {
            var color = SPTMeshLook.get(object: object).shading.blinnPhong.color.hsba
            switch animatableProperty {
            case .hue:
                color.hue = binding.valueAt0
            case .saturation:
                color.saturation = binding.valueAt0
            case .brightness:
                color.brightness = binding.valueAt0
            default:
                fatalError()
            }
            return color
        }
        set {
            switch animatableProperty {
            case .hue:
                binding.valueAt0 = newValue.hue
            case .saturation:
                binding.valueAt0 = newValue.saturation
            case .brightness:
                binding.valueAt0 = newValue.brightness
            default:
                fatalError()
            }
        }
    }
    
    var value1HSBAColor: SPTHSBAColor {
        get {
            var color = SPTMeshLook.get(object: object).shading.blinnPhong.color.hsba
            switch animatableProperty {
            case .hue:
                color.hue = binding.valueAt1
            case .saturation:
                color.saturation = binding.valueAt1
            case .brightness:
                color.brightness = binding.valueAt1
            default:
                fatalError()
            }
            return color
        }
        set {
            switch animatableProperty {
            case .hue:
                binding.valueAt1 = newValue.hue
            case .saturation:
                binding.valueAt1 = newValue.saturation
            case .brightness:
                binding.valueAt1 = newValue.brightness
            default:
                fatalError()
            }
        }
    }
    
    var hsbColorChannel: HSBColorChannel {
        switch animatableProperty {
        case .hue:
            return .hue
        case .saturation:
            return .saturation
        case .brightness:
            return .brightness
        default:
            fatalError()
        }
    }

    private func updateChannelValue(property: AnimatorBindingComponentProperty) {
        switch property {
        case .valueAt0:
            self.channelValue = self.binding.valueAt0
        case .valueAt1:
            self.channelValue = self.binding.valueAt1
        case .animator:
            self.channelValue = self.channelInitialValue
        }
    }
    
    static var defaultValueAt0: Float { 0 }
    
    static var defaultValueAt1: Float { 1 }
    
}


struct ObjectHSBAColorChannelAnimatorBindingComponentView: View {
    
    @ObservedObject var component: ObjectHSBAColorChannelAnimatorBindingComponent
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                HSBColorSelector(hsbaColor: $component.value0HSBAColor, channel: component.hsbColorChannel) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
                .tint(Color.primarySelectionColor)
            case .valueAt1:
                HSBColorSelector(hsbaColor: $component.value1HSBAColor, channel: component.hsbColorChannel) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
                .tint(Color.primarySelectionColor)
            case .none:
                EmptyView()
            }
        }
        .transition(.identity)
        .onAppear {
            component.onAppear()
        }
        .onDisappear {
            component.onDisappear()
        }
    }
    
}

