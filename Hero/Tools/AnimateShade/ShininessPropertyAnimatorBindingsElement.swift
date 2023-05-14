//
//  ShininessPropertyAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.05.23.
//

import SwiftUI


struct ShininessPropertyAnimatorBindingsElement: PropertyAnimatorBindingElement {
    
    typealias Property = AnimatorBindingProperty
    
    let title: String
    @Binding var propertyValue: Float
    let animatableProperty: SPTAnimatableObjectProperty
    let object: SPTObject
    let guideColor: UIColor
    let activeGuideColor: UIColor
    
    @ObjectElementActiveProperty var activeProperty: Property
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>>
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var _showsAnimatorSelector: State<Bool>
    @State var initialPropertyValue: Float!
    
    init(title: String, propertyValue: Binding<Float>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, guideColor: UIColor = .guide1Dark, activeGuideColor: UIColor = .guide1Light) {
        self.title = title
        _propertyValue = propertyValue
        self.animatableProperty = animatableProperty
        self.object = object
        self.guideColor = guideColor
        self.activeGuideColor = activeGuideColor
        
        _activeProperty = .init(object: object, elementId: animatableProperty)
        _binding = .init(wrappedValue: .init(property: animatableProperty, object: object))
        
        _showsAnimatorSelector = .init(wrappedValue: false)
    }
    
    var actionView: some View {
        switch activeProperty {
        case .valueAt0:
            ObjectFloatPropertySlider(value: _binding.projectedValue.valueAt0)
                .tint(Color(uiColor: activeGuideColor))
        case .valueAt1:
            ObjectFloatPropertySlider(value: _binding.projectedValue.valueAt1)
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
    
    var defaultValueAt0: Float { 0.0 }
    var defaultValueAt1: Float { 1.0 }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
