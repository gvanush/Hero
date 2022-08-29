//
//  ComponentSetupViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.08.22.
//

import Foundation
import SwiftUI


protocol ComponentSetupViewProvider {
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>, onComplete: @escaping () -> Void) -> AnyView where AP: SPTAnimatableProperty
    
}


struct CommonComponentSetupViewProvider: ComponentSetupViewProvider {
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>,  onComplete: @escaping () -> Void) -> AnyView where AP : SPTAnimatableProperty {
        AnyView(AnimatorSelector { animatorId in
            if let animatorId = animatorId {
                component.bindAnimator(id: animatorId)
            }
            onComplete()
        })
    }
        
}
