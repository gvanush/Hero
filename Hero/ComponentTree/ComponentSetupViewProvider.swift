//
//  ComponentSetupViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.08.22.
//

import Foundation
import SwiftUI


protocol ComponentSetupViewProvider {
    
    func viewFor<AnimatorBindingComponent>(_ component: AnimatorBindingSetupComponent<AnimatorBindingComponent>, onComplete: @escaping () -> Void) -> AnyView
    
}


class EmptyComponentSetupViewProvider: ComponentSetupViewProvider {
    
    func viewFor<AnimatorBindingComponent>(_ component: AnimatorBindingSetupComponent<AnimatorBindingComponent>, onComplete: @escaping () -> Void) -> AnyView {
        AnyView(EmptyView())
    }
    
}


struct CommonComponentSetupViewProvider: ComponentSetupViewProvider {
    
    func viewFor<AnimatorBindingComponent>(_ component: AnimatorBindingSetupComponent<AnimatorBindingComponent>,  onComplete: @escaping () -> Void) -> AnyView {
        AnyView(
            AnimatorSelector { animatorId in
                if let animatorId = animatorId {
                    component.bindAnimator(id: animatorId)
                }
                onComplete()
            }
        )
    }
        
}
