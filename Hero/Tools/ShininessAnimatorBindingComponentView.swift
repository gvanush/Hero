//
//  ShininessAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.11.22.
//

import SwiftUI


class ShininessAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var shininessInitialValue: Float!
    
    @SPTObservedComponentProperty<SPTMeshLook, Float> var shininess: Float
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        guard animatableProperty == .shininess else {
            fatalError()
        }
        
        _shininess = .init(object: object, keyPath: \.shading.blinnPhong.shininess)
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        _shininess.publisher = self.objectWillChange
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty? {
        didSet {
            if isActive {
                updateLookPropertyValue()
            }
        }
    }
    
    override func onActive() {
        shininessInitialValue = shininess
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingDidChangeSink(object: object, callback: { [unowned self] _ in
            self.updateLookPropertyValue()
        })
        
        updateLookPropertyValue()
    }
    
    override func onInactive() {
        shininess = shininessInitialValue
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }

    private func updateLookPropertyValue() {
        switch selectedProperty! {
        case .valueAt0:
            self.shininess = self.binding.valueAt0
        case .valueAt1:
            self.shininess = self.binding.valueAt1
        case .animator:
            self.shininess = self.shininessInitialValue
        }
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

