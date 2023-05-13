//
//  UniformScalePropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.05.23.
//

import SwiftUI


struct UniformScalePropertyAnimatorBindingElement: ScalePropertyAnimatorBindingElement {
    
    typealias Property = AnimatorBindingProperty
    
    let title: String
    @Binding var propertyValue: Float
    let animatableProperty: SPTAnimatableObjectProperty
    let object: SPTObject
    let defaultValueAt0: Float
    let defaultValueAt1: Float
    let guideColor: UIColor
    let activeGuideColor: UIColor
    
    @ObjectElementActiveProperty var activeProperty: Property
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>>
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var _showsAnimatorSelector: State<Bool>
    @State var initialPropertyValue: Float!
    
    init(title: String, propertyValue: Binding<Float>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, defaultValueAt0: Float, defaultValueAt1: Float, guideColor: UIColor = .guide1Dark, activeGuideColor: UIColor = .guide1Light) {
        self.title = title
        _propertyValue = propertyValue
        self.animatableProperty = animatableProperty
        self.object = object
        self.defaultValueAt0 = defaultValueAt0
        self.defaultValueAt1 = defaultValueAt1
        self.guideColor = guideColor
        self.activeGuideColor = activeGuideColor
        
        _activeProperty = .init(object: object, elementId: animatableProperty)
        _binding = .init(wrappedValue: .init(property: animatableProperty, object: object))
        
        _showsAnimatorSelector = .init(wrappedValue: false)
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
