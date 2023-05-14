//
//  PropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.05.23.
//

import SwiftUI

enum AnimatorBindingProperty: Int, ElementProperty {
    case valueAt0
    case valueAt1
    
    var displayName: String {
        switch self {
        case .valueAt0:
            return "Value:0"
        case .valueAt1:
            return "Value:1"
        }
    }
}

protocol PropertyAnimatorBindingElement: Element where Property == AnimatorBindingProperty {
    
    var object: SPTObject { get }
    
    var animatableProperty: SPTAnimatableObjectProperty { get }
    
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>> { get }
    
    var _showsAnimatorSelector: State<Bool> { get }
    
    var defaultValueAt0: Float { get }
    
    var defaultValueAt1: Float { get }
    
    var sceneViewModel: SceneViewModel { get }
    
}

extension PropertyAnimatorBindingElement {
    
    var optionsView: some View {
        AnimatorBindingOptionsView(property: animatableProperty, object: object)
    }
    
    func onPrepare() {
        showsAnimatorSelector = true
    }
    
    var isReady: Bool {
        animatableProperty.isAnimatorBound(object: object)
    }
    
    var animatorBindingElementBody: some View {
        elementBody
            .sheet(isPresented: _showsAnimatorSelector.projectedValue) {
                AnimatorSelector { animatorId in
                    if let animatorId {
                        animatableProperty.bind(.init(animatorId: animatorId, valueAt0: defaultValueAt0, valueAt1: defaultValueAt1), object: object)
                        activeIndexPath = indexPath
                    }
                    showsAnimatorSelector = false
                }
            }
    }
    
    var body: some View {
        animatorBindingElementBody
    }
    
    var subtitle: String? {
        if let animatorId = binding.value?.animatorId {
            return SPTAnimator.get(id: animatorId).name
        }
        return nil
    }
    
    var id: some Hashable {
        animatableProperty
    }
    
    var binding: SPTObservableAnimatorBinding<SPTAnimatableObjectProperty> {
        _binding.wrappedValue
    }
    
    var showsAnimatorSelector: Bool {
        get {
            _showsAnimatorSelector.wrappedValue
        }
        nonmutating set {
            _showsAnimatorSelector.wrappedValue = newValue
        }
    }
    
}
