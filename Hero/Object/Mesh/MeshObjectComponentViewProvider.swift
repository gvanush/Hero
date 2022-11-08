//
//  MeshObjectComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


class MeshObjectComponentViewProvider<RC>: ComponentViewProvider<RC> {
    
    override func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty {
        AnyView(AnimatorBindingComponentView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectColorView(component: component, viewProvider: self))
    }
    
    override func viewFor<C>(_ component: ObjectRGBAColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectRGBAColorComponentView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectHSBAColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectHSBAColorComponentView(component: component))
    }

}

