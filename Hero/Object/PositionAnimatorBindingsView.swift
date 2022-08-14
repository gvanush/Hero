//
//  PositionAnimatorBindingsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


class PositionAnimatorBindingsComponent: Component {
    
    static let title = "Animators"
    
    let object: SPTObject
    lazy private(set) var x = AnimatorBindingComponent(title: "X", object: self.object, parent: self)
    lazy private(set) var y = AnimatorBindingComponent(title: "Y", object: self.object, parent: self)
    lazy private(set) var z = AnimatorBindingComponent(title: "Z", object: self.object, parent: self)
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: Self.title, parent: parent)
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
}


struct PositionAnimatorBindingsView: View {
    
    @ObservedObject var component: PositionAnimatorBindingsComponent
    @Binding var editedComponent: Component?
    
    static let navigationTitle = "Animators"
    
    var body: some View {
        Form {
            Section("X") {
                AnimatorBindingComponentView(component: component.x, editedComponent: $editedComponent)
            }
            Section("Y") {
                AnimatorBindingComponentView(component: component.y, editedComponent: $editedComponent)
            }
            Section("Z") {
                AnimatorBindingComponentView(component: component.z, editedComponent: $editedComponent)
            }
        }
        .navigationTitle(Self.navigationTitle)
    }
}
