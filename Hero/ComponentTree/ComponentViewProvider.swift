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
    
}

final class EmptyComponentViewProvider<RC>: ComponentViewProvider<RC> {
    
}
