//
//  AnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

import Foundation
import SwiftUI
import Combine


enum AnimatorBindingComponentProperty: Int, DistinctValueSet, Displayable {
    
    case animator
    case valueAt0
    case valueAt1
    
    var displayName: String {
        switch self {
        case .animator:
            return "Animator"
        case .valueAt0:
            return "Value:0"
        case .valueAt1:
            return "Value:1"
        }
    }
}


class AnimatorBindingComponent<AP>: BasicComponent<AnimatorBindingComponentProperty> where AP: SPTAnimatableProperty {
    
    class Binding: ObservableObject {
        
        @SPTObservedAnimatorBinding<AP> var sptBinding: SPTAnimatorBinding
        
        init(animatableProperty: AP, object: SPTObject) {
            _sptBinding = SPTObservedAnimatorBinding(property: animatableProperty, object: object)
            _sptBinding.publisher = objectWillChange
        }
        
        var animatorId: SPTAnimatorId {
            set {
                sptBinding.animatorId = newValue
            }
            get {
                sptBinding.animatorId
            }
        }
        
        var valueAt0: Float {
            set { sptBinding.valueAt0 = newValue }
            get { sptBinding.valueAt0 }
        }

        var valueAt1: Float {
            set { sptBinding.valueAt1 = newValue }
            get { sptBinding.valueAt1 }
        }
        
    }
    
    let animatableProperty: AP
    let object: SPTObject
    
    @Published var binding: Binding?
    private var bindingCancellable: AnyCancellable?
    
    @Published var isControllingAnimator = false
    
    init(animatableProperty: AP, title: String, object: SPTObject, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.object = object
        
        super.init(title: title, selectedProperty: .valueAt0, parent: parent)
        
        if animatableProperty.isAnimatorBound(object: object) {
            setupBinding()
        }
    
        self.actions.append(.init(iconName: "bolt.slash", action: { [weak self] in
            self?.unbindAnimator()
        }))
    }
    
    var animator: SPTAnimator? {
        guard let binding = self.binding else { return nil }
        return SPTAnimatorGet(binding.sptBinding.animatorId)
    }
    
    func bindAnimator(id: SPTAnimatorId) {
        animatableProperty.bindOrUpdate(.init(animatorId: id, valueAt0: -10.0, valueAt1: 10.0), object: object)
        
        setupBinding()
    }
    
    func unbindAnimator() {
        binding = nil
        bindingCancellable = nil
        animatableProperty.unbindAnimator(object: object)
    }
    
    override var isSetup: Bool {
        binding != nil
    }
    
    override func accept(_ provider: ComponentActionViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
    override func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        provider.viewFor(self, onComplete: onComplete)
    }
    
    private func setupBinding() {
        let newBinding = Binding(animatableProperty: animatableProperty, object: object)
        bindingCancellable = newBinding.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
        binding = newBinding
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
            
            if let animatorBinding = component.binding {
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
    
    var body: some View {
        if let property = component.selectedProperty, let animatorBinding = component.binding {
            ContentView(property: property, binding: animatorBinding)
        }
    }
    
    private struct ContentView: View {
        
        let property: AnimatorBindingComponentProperty
        @ObservedObject var binding: AnimatorBindingComponent<AP>.Binding
        
        @State private var scale = FloatSelector.Scale._1
        @State private var isSnappingEnabled = false
        
        var body: some View {
            Group {
                switch property {
                case .animator:
                    AnimatorControl(animatorId: $binding.animatorId)
                case .valueAt0:
                    FloatSelector(value: $binding.valueAt0, scale: $scale, isSnappingEnabled: $isSnappingEnabled)
                case .valueAt1:
                    FloatSelector(value: $binding.valueAt1, scale: $scale, isSnappingEnabled: $isSnappingEnabled)
                }
            }
            .transition(.identity)
        }
        
    }
    
}
