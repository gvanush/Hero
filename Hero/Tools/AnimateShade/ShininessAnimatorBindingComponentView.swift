//
//  ShininessAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.11.22.
//

import SwiftUI
import Combine


class ShininessAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty, ShininessAnimatorBindingComponent.EditingParams>, AnimatorBindingComponentProtocol {
    
    struct EditingParams {
    }
    
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var selectedPropertySubscription: AnyCancellable?
    private var initialShininess: Float!
    
    @SPTObservedComponentProperty<SPTMeshLook, Float> var shininess: Float
    
    required init(editingParams: EditingParams, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        _shininess = .init(object: object, keyPath: \.shading.blinnPhong.shininess)
        
        super.init(editingParams: editingParams, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        _shininess.publisher = self.objectWillChange
    }
    
    func onAppear() {
        initialShininess = shininess
        
        selectedPropertySubscription = self.$selectedProperty.sink { [weak self] newValue in
            guard let property = newValue, let self = self else { return }
            self.updateShininess(property: property)
        }
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [weak self] newValue in
            guard let self = self, let property = self.selectedProperty else { return }

            self.updateShininess(property: property)

        })
    }
    
    func onDisappear() {
        shininess = initialShininess
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }

    private func updateShininess(property: AnimatorBindingComponentProperty) {
        switch property {
        case .valueAt0:
            self.shininess = self.binding.valueAt0
        case .valueAt1:
            self.shininess = self.binding.valueAt1
        case .animator:
            self.shininess = self.initialShininess
        }
    }
    
    static var defaultValueAt0: Float { 0 }
    
    static var defaultValueAt1: Float { 1 }
    
}


struct ShininessAnimatorBindingView: View {
    
    @ObservedObject var component: ShininessAnimatorBindingComponent
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSlider(value: $component.binding.valueAt0)
                    .tint(Color.primarySelectionColor)
            case .valueAt1:
                FloatSlider(value: $component.binding.valueAt1)
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

