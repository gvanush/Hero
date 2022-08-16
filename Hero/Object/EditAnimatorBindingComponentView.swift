//
//  AnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

import Foundation
import SwiftUI

enum AnimatorBindingComponentProperty: Int, DistinctValueSet, Displayable {
    case valueAt0
    case valueAt1
}

class AnimatorBindingComponent<AP>: BasicComponent<AnimatorBindingComponentProperty> where AP: SPTAnimatableProperty {
    
    @SPTObservedOptionalAnimatorBinding<AP> var animatorBinding: SPTAnimatorBinding?
    
    init(animatableProperty: AP, title: String, object: SPTObject, parent: Component?) {
        
        _animatorBinding = SPTObservedOptionalAnimatorBinding(property: animatableProperty, object: object)
        
        super.init(title: title, selectedProperty: .valueAt0, parent: parent)
        
        _animatorBinding.publisher = self.objectWillChange
    }
    
    var valueAt0: Float {
        set { animatorBinding!.valueAt0 = newValue }
        get { animatorBinding!.valueAt0 }
    }
    
    var valueAt1: Float {
        set { animatorBinding!.valueAt1 = newValue }
        get { animatorBinding!.valueAt1 }
    }
    
    var animator: SPTAnimator? {
        guard let animatorBinding = self.animatorBinding else { return nil }
        return SPTAnimatorGet(animatorBinding.animatorId)
    }
    
    func bindAnimator(id: SPTAnimatorId) {
        animatorBinding = SPTAnimatorBinding(animatorId: id, valueAt0: 0.0, valueAt1: 100.0)
    }
    
    func unbindAnimator() {
        animatorBinding = nil
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct AnimatorBindingComponentView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    @Binding var editedComponent: Component?
    @State private var showsAnimatorSelector = false;
    
    var body: some View {
        Group {
            LabeledContent("Animator") {
                if let animator = component.animator {
                    Text(animator.name)
                    Button {
                        component.unbindAnimator()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .imageScale(.large)
                    }
                } else {
                    Image(systemName: "minus")
                        .foregroundColor(.quaternaryLabel)
                    Button {
                        showsAnimatorSelector = true
                    } label: {
                        Image(systemName: "circlebadge.2")
                            .imageScale(.large)
                    }
                }
                
            }
            
            if let animatorBinding = component.animatorBinding {
                SceneEditableParam(title: AnimatorBindingComponentProperty.valueAt0.displayName, value: "\(animatorBinding.valueAt0)") {
                    component.selectedProperty = .valueAt0
                    editedComponent = component
                }
                SceneEditableParam(title: AnimatorBindingComponentProperty.valueAt1.displayName, value: "\(animatorBinding.valueAt1)") {
                    component.selectedProperty = .valueAt1
                    editedComponent = component
                }
            }
        }
        .sheet(isPresented: $showsAnimatorSelector) {
            AnimatorSelector { animatorId in
                component.bindAnimator(id: animatorId)
            }
        }
    }
    
}


struct EditAnimatorBindingComponentView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    @State private var scale = FloatField.Scale._1
    
    var body: some View {
        if let property = component.selectedProperty {
            switch property {
            case .valueAt0:
                FloatField(value: $component.valueAt0, scale: $scale)
                    .transition(.identity)
            case .valueAt1:
                FloatField(value: $component.valueAt1, scale: $scale)
                    .transition(.identity)
            }
                
        }
    }
}
