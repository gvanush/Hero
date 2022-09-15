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
    case animator
    
    var displayName: String {
        switch self {
        case .valueAt0:
            return "Value:0"
        case .valueAt1:
            return "Value:1"
        case .animator:
            return "Animator"
        }
    }
}

class AnimatorBindingComponent<AP>: BasicComponent<AnimatorBindingComponentProperty> where AP: SPTAnimatableProperty {
    
    let animatableProperty: AP
    let object: SPTObject
    @SPTObservedOptionalAnimatorBinding<AP> var animatorBinding: SPTAnimatorBinding?
    @Published var animatorValue: Float = 0.5
    
    init(animatableProperty: AP, title: String, object: SPTObject, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.object = object
        
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
        animatorBinding = SPTAnimatorBinding(animatorId: id, valueAt0: -10.0, valueAt1: 10.0)
    }
    
    func unbindAnimator() {
        animatorBinding = nil
    }
    
    override var isSetup: Bool {
        animatorBinding != nil
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
    override func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        provider.viewFor(self, onComplete: onComplete)
    }
    
}


struct AnimatorBindingComponentView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    @Binding var editedComponent: Component?
    @State private var showsAnimatorSelector = false;
    
    var body: some View {
        Group {
            LabeledContent("Animator") {
                Group {
                    if let animator = component.animator {
                        Text(animator.name)
                    }
                    Button(role: (component.isSetup ? .destructive : nil)) {
                        if component.isSetup {
                            component.unbindAnimator()
                        } else {
                            showsAnimatorSelector = true
                        }
                    } label: {
                        Image(systemName: component.animator == nil ? "minus" : "xmark.circle")
                            .imageScale(.large)
                    }
                    // NOTE: This is necessary for an unknown reason to prevent 'Form' row
                    // from being selectable when there is a button inside.
                    .buttonStyle(BorderlessButtonStyle())
                    .tint(Color.lightAccentColor)

                }
            }
            
            if let animatorBinding = component.animatorBinding {
                SceneEditableParam(title: AnimatorBindingComponentProperty.valueAt0.displayName, value: String(format: "%.2f", animatorBinding.valueAt0)) {
                    component.selectedProperty = .valueAt0
                    editedComponent = component
                }
                SceneEditableParam(title: AnimatorBindingComponentProperty.valueAt1.displayName, value: String(format: "%.2f", animatorBinding.valueAt1)) {
                    component.selectedProperty = .valueAt1
                    editedComponent = component
                }
            }
        }
        .sheet(isPresented: $showsAnimatorSelector) {
            AnimatorSelector { animatorId in
                if let animatorId = animatorId {
                    component.bindAnimator(id: animatorId)
                }
                showsAnimatorSelector = false
            }
        }
    }
    
}


struct EditAnimatorBindingComponentView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    @State private var scale = FloatSelector.Scale._1
    @State private var isSnappingEnabled = false
    
    var body: some View {
        Group {
            if let property = component.selectedProperty {
                switch property {
                case .valueAt0:
                    FloatSelector(value: $component.valueAt0, scale: $scale, isSnappingEnabled: $isSnappingEnabled)
                case .valueAt1:
                    FloatSelector(value: $component.valueAt1, scale: $scale, isSnappingEnabled: $isSnappingEnabled)
                case .animator:
                    FloatSlider(value: $component.animatorValue)
                }
            }
        }
        .transition(.identity)
    }
}
