//
//  ObjectHSBAColorChannelAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.22.
//

import SwiftUI


class ObjectHSBAColorChannelAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private let channelKeyPath: WritableKeyPath<SPTMeshLook, Float>
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var guideObject: SPTObject!
    
    required override init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        switch animatableProperty {
        case .hue:
            channelKeyPath = \.shading.blinnPhong.color.hsba.hue
        case .saturation:
            channelKeyPath = \.shading.blinnPhong.color.hsba.saturation
        case .brightness:
            channelKeyPath = \.shading.blinnPhong.color.hsba.brightness
        default:
            fatalError()
        }
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty? {
        didSet {
            if isActive {
                updateChannelValue()
            }
        }
    }
    
    override func onActive() {
        
        // Clone source object to display resulting color
        guideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guideObject)
        SPTScale.make(SPTScale.get(object: object), object: guideObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: guideObject)
        var meshLook = SPTMeshLook.get(object: object)
        meshLook.categories = LookCategories.guide.rawValue
        SPTMeshLook.make(meshLook, object: guideObject)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingDidChangeSink(object: object, callback: { [unowned self] newValue in
            self.updateChannelValue()
        })
        
        updateChannelValue()
    }
    
    override func onInactive() {
        bindingWillChangeSubscription = nil
        SPTSceneProxy.destroyObject(guideObject)
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

    private func updateChannelValue() {
        switch selectedProperty! {
        case .valueAt0:
            updateGuideChannel(self.binding.valueAt0)
        case .valueAt1:
            updateGuideChannel(self.binding.valueAt1)
        case .animator:
            updateGuideChannel(SPTMeshLook.get(object: object)[keyPath: channelKeyPath])
        }
    }
    
    private func updateGuideChannel(_ value: Float) {
        var meshLook = SPTMeshLook.get(object: guideObject)
        meshLook[keyPath: channelKeyPath] = value
        SPTMeshLook.update(meshLook, object: guideObject)
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
    }
    
}

