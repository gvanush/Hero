//
//  MeshObjectComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


struct MeshObjectComponentViewProvider: ComponentViewProvider {
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty {
        AnyView(AnimatorBindingComponentView(component: component))
    }

}

