//
//  ShininessAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.11.22.
//

import SwiftUI


class ShininessAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var guideObject: SPTObject!
    
    required override init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        guard animatableProperty == .shininess else {
            fatalError()
        }
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty? {
        didSet {
            if isActive {
                updateLookPropertyValue()
            }
        }
    }
    
    override func onActive() {
        
        // Clone source object to display resulting shininess
        guideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guideObject)
        SPTScale.make(SPTScale.get(object: object), object: guideObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: guideObject)
        SPTMeshLook.make(SPTMeshLook.get(object: object), object: guideObject)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingDidChangeSink(object: object, callback: { [unowned self] _ in
            self.updateLookPropertyValue()
        })
        
        updateLookPropertyValue()
    }
    
    override func onInactive() {
        bindingWillChangeSubscription = nil
        SPTSceneProxy.destroyObject(guideObject)
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }

    private func updateLookPropertyValue() {
        switch selectedProperty! {
        case .valueAt0:
            updateGuideShininess(self.binding.valueAt0)
        case .valueAt1:
            updateGuideShininess(self.binding.valueAt1)
        case .animator:
            updateGuideShininess(SPTMeshLook.get(object: object).shading.blinnPhong.shininess)
        }
    }
    
    private func updateGuideShininess(_ shininess: Float) {
        var meshLook = SPTMeshLook.get(object: guideObject)
        meshLook.shading.blinnPhong.shininess = shininess
        SPTMeshLook.update(meshLook, object: guideObject)
    }
    
    static var defaultValueAt0: Float { 0 }
    
    static var defaultValueAt1: Float { 1 }
    
}


struct ShininessAnimatorBindingComponentView: View {
    
    @ObservedObject var component: ShininessAnimatorBindingComponent
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSlider(value: $component.binding.valueAt0) { isEditing in
                    userInteractionState.isEditing = isEditing
                }
                .tint(Color.primarySelectionColor)
            case .valueAt1:
                FloatSlider(value: $component.binding.valueAt1) { isEditing in
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

