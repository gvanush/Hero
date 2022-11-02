//
//  ComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import Foundation
import SwiftUI


class ComponentViewProvider<RC> {
    
    func viewForRoot(_ root: RC) -> AnyView? { nil }
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty { nil }
    
    func viewFor<C>(_ component: ObjectColorComponent<C>) -> AnyView? where C: SPTObservableComponent { nil }
    
}

final class EmptyComponentViewProvider<RC>: ComponentViewProvider<RC> {
    
}
