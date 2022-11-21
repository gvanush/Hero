//
//  ObjectRGBAColorChannelAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.22.
//

import SwiftUI
import Combine


class ObjectRGBAColorChannelAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var selectedPropertySubscription: AnyCancellable?
    private var channelInitialValue: Float!
    
    @SPTObservedComponentProperty<SPTMeshLook, Float> var channelValue: Float
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        var keyPath: WritableKeyPath<SPTMeshLook, Float>!
        switch animatableProperty {
        case .red:
            keyPath = \.shading.blinnPhong.color.rgba.red
        case .green:
            keyPath = \.shading.blinnPhong.color.rgba.green
        case .blue:
            keyPath = \.shading.blinnPhong.color.rgba.blue
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
    
    var value0RGBAColor: SPTRGBAColor {
        get {
            var color = SPTMeshLook.get(object: object).shading.blinnPhong.color.rgba
            switch animatableProperty {
            case .red:
                color.red = binding.valueAt0
            case .green:
                color.green = binding.valueAt0
            case .blue:
                color.blue = binding.valueAt0
            default:
                fatalError()
            }
            return color
        }
        set {
            switch animatableProperty {
            case .red:
                binding.valueAt0 = newValue.red
            case .green:
                binding.valueAt0 = newValue.green
            case .blue:
                binding.valueAt0 = newValue.blue
            default:
                fatalError()
            }
        }
    }
    
    var value1RGBAColor: SPTRGBAColor {
        get {
            var color = SPTMeshLook.get(object: object).shading.blinnPhong.color.rgba
            switch animatableProperty {
            case .red:
                color.red = binding.valueAt1
            case .green:
                color.green = binding.valueAt1
            case .blue:
                color.blue = binding.valueAt1
            default:
                fatalError()
            }
            return color
        }
        set {
            switch animatableProperty {
            case .red:
                binding.valueAt1 = newValue.red
            case .green:
                binding.valueAt1 = newValue.green
            case .blue:
                binding.valueAt1 = newValue.blue
            default:
                fatalError()
            }
        }
    }
    
    var rgbColorChannel: RGBColorChannel {
        switch animatableProperty {
        case .red:
            return .red
        case .green:
            return .green
        case .blue:
            return .blue
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


struct ObjectRGBAColorChannelAnimatorBindingComponentView: View {
    
    @ObservedObject var component: ObjectRGBAColorChannelAnimatorBindingComponent
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                RGBColorSelector(rgbaColor: $component.value0RGBAColor, channel: component.rgbColorChannel) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
                .tint(Color.primarySelectionColor)
            case .valueAt1:
                RGBColorSelector(rgbaColor: $component.value1RGBAColor, channel: component.rgbColorChannel) { isEditing in
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

