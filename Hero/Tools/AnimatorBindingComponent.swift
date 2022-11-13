//
//  AnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.11.22.
//

import Foundation


protocol AnimatorBindingComponentProtocol: ObservableObject {
    
    associatedtype AP: SPTAnimatableProperty & Displayable
    associatedtype EditingParams
    
    init(editingParams: EditingParams, animatableProperty: AP, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?)
    
    var selectedProperty: AnimatorBindingComponentProperty? { set get }
    
    var editingParams: EditingParams { get }
    
    static var defaultValueAt0: Float { get }
    
    static var defaultValueAt1: Float { get }
}


class AnimatorBindingComponentBase<AnimatableProperty, EditingParams>: BasicComponent<AnimatorBindingComponentProperty> where AnimatableProperty: SPTAnimatableProperty & Displayable {
    
    let animatableProperty: AnimatableProperty
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    @Published var editingParams: EditingParams
    
    @SPTObservedAnimatorBinding<AnimatableProperty> var binding: SPTAnimatorBinding
    
    required init(editingParams: EditingParams, animatableProperty: AnimatableProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.object = object
        self.editingParams = editingParams
        self.sceneViewModel = sceneViewModel
        
        _binding = .init(property: animatableProperty, object: object)
        
        super.init(selectedProperty: .valueAt0, parent: parent)
        
        _binding.publisher = self.objectWillChange
    }
    
}
