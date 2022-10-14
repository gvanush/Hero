//
//  ComponentActionViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import Foundation
import SwiftUI


protocol ComponentActionViewProvider {
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty
    
}


extension ComponentActionViewProvider {

    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty { nil }
    
}

struct EmptyComponentActionViewProvider: ComponentActionViewProvider {
    
}
