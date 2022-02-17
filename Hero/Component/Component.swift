//
//  Component.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.02.22.
//

import Foundation
import SwiftUI


class Component: Identifiable, ObservableObject {
    
    let title: String
    private(set) weak var parent: Component?
    
    init(title: String, parent: Component?) {
        self.title = title
        self.parent = parent
    }
    
    var id: Component { self }
    var properties: [String]? { nil }
    var activePropertyIndex: Int? {
        set { }
        get { nil }
    }
    var subcomponents: [Component]? { nil }
    
    func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        nil
    }
    
    func onWillChange() {
        objectWillChange.send()
        if let subcomponents = self.subcomponents {
            for subcomponent in subcomponents {
                subcomponent.onWillChange()
            }
        }
    }
}
