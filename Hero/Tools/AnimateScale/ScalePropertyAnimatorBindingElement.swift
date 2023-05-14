//
//  ScalePropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.05.23.
//

import SwiftUI


protocol ScalePropertyAnimatorBindingElement: PropertyAnimatorBindingElement {
    
    var propertyValue: Float { get nonmutating set }
    
    var initialPropertyValue: Float! { get nonmutating set }
    
    var guideColor: UIColor { get }
    
    var activeGuideColor: UIColor { get }
}

extension ScalePropertyAnimatorBindingElement {
    
    @ViewBuilder
    var actionView: some View {
        switch activeProperty {
        case .valueAt0:
            ObjectFloatPropertySelector(object: object, id: SPTAnimatorBindingPropertyId(animatableProperty: animatableProperty, propertyKeyPath: \.valueAt0), value: _binding.projectedValue.valueAt0, formatter: Formatters.scale)
                .tint(Color(uiColor: activeGuideColor))
        case .valueAt1:
            ObjectFloatPropertySelector(object: object, id: SPTAnimatorBindingPropertyId(animatableProperty: animatableProperty, propertyKeyPath: \.valueAt1), value: _binding.projectedValue.valueAt1, formatter: Formatters.scale)
                .tint(Color(uiColor: activeGuideColor))
        }
    }
    
    var body: some View {
        animatorBindingElementBody
            .onChange(of: binding.value) { newValue in
                guard let binding = newValue else {
                    return
                }
                updatePropertyValue(binding: binding)
            }
    }
    
    func onActivePropertyChange() {
        updatePropertyValue(binding: binding.value!)
    }
    
    func onDisclose() {
        initialPropertyValue = propertyValue
        
        updatePropertyValue(binding: binding.value!)
    }
    
    func onClose() {
        propertyValue = initialPropertyValue
    }
    
    func updatePropertyValue(binding: SPTAnimatorBinding) {
        switch activeProperty {
        case .valueAt0:
            propertyValue = binding.valueAt0
        case .valueAt1:
            propertyValue = binding.valueAt1
        }
    }
    
}
