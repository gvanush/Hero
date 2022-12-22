//
//  ObjectRGBAColorChannelAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.22.
//

import SwiftUI


class ObjectRGBAColorChannelAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private let channelKeyPath: WritableKeyPath<SPTMeshLook, Float>
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var guideObject: SPTObject!
    
    
    required override init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        switch animatableProperty {
        case .red:
            channelKeyPath = \.shading.blinnPhong.color.rgba.red
        case .green:
            channelKeyPath = \.shading.blinnPhong.color.rgba.green
        case .blue:
            channelKeyPath = \.shading.blinnPhong.color.rgba.blue
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
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingDidChangeSink(object: object, callback: { [unowned self] _ in
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
    }
    
}

