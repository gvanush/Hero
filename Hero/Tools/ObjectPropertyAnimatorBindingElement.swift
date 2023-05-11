//
//  ObjectPropertyAnimatorBindingElement.swift
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

protocol ObjectPropertyAnimatorBindingElement: Element where Property == AnimatorBindingProperty {
    
    var object: SPTObject { get }
    
    var animatableProperty: SPTAnimatableObjectProperty { get }
    
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>> { get }
    
    var guideColor: UIColor { get }
    
    var activeGuideColor: UIColor { get }
    
    var _showsAnimatorSelector: State<Bool> { get }
    
    var defaultValueAt0: Float { get }
    
    var defaultValueAt1: Float { get }
    
    var point0Object: SPTObject! { get }
    
    var point1Object: SPTObject! { get }
    
    var sceneViewModel: SceneViewModel { get }
    
}

extension ObjectPropertyAnimatorBindingElement {
    
    var optionsView: some View {
        AnimatorBindingOptionsView(property: animatableProperty, object: object)
    }
    
    func onActivePropertyChange() {
        var point0Look = SPTPointLook.get(object: point0Object)
        var point1Look = SPTPointLook.get(object: point1Object)
        
        switch activeProperty {
        case .valueAt0:
            point0Look.color = activeGuideColor.rgba
            point1Look.color = guideColor.rgba
            sceneViewModel.focusedObject = point0Object
        case .valueAt1:
            point0Look.color = guideColor.rgba
            point1Look.color = activeGuideColor.rgba
            sceneViewModel.focusedObject = point1Object
        }
        
        SPTPointLook.update(point0Look, object: point0Object)
        SPTPointLook.update(point1Look, object: point1Object)
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
                    }
                    showsAnimatorSelector = false
                    activeIndexPath = indexPath
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
