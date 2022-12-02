//
//  AnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.11.22.
//

import Foundation


protocol AnimatorBindingComponentProtocol: ObservableObject {
    
    associatedtype AP: SPTAnimatableProperty & Displayable
    
    init(animatableProperty: AP, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?)
    
    var selectedProperty: AnimatorBindingComponentProperty? { set get }
    
    static var defaultValueAt0: Float { get }
    
    static var defaultValueAt1: Float { get }
}


class AnimatorBindingComponentBase<AnimatableProperty>: BasicComponent<AnimatorBindingComponentProperty> where AnimatableProperty: SPTAnimatableProperty & Displayable {
    
    let animatableProperty: AnimatableProperty
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @SPTObservedAnimatorBinding<AnimatableProperty> var binding: SPTAnimatorBinding
    
    init(animatableProperty: AnimatableProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _binding = .init(property: animatableProperty, object: object)
        
        super.init(selectedProperty: .valueAt0, parent: parent)
        
        _binding.publisher = self.objectWillChange
    }
    
}
