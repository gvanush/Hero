//
//  ComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import Foundation
import SwiftUI


protocol ComponentViewProvider {
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty
    
}


extension ComponentViewProvider {

    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty { nil }
    
}

struct EmptyComponentViewProvider: ComponentViewProvider {
    
}
