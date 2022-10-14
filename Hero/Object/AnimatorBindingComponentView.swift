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
    
    let animatableProperty: AP
    let object: SPTObject
    
    @Published var editViewModel: EditAnimatorBindingViewModel<AP>?
    
    private var bindingWillEmergeSubscription: SPTAnySubscription?
    private var bindingWillPerishSubscription: SPTAnySubscription?
    
    init(animatableProperty: AP, title: String, object: SPTObject, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.object = object
        
        super.init(title: title, selectedProperty: .valueAt0, parent: parent)
        
        bindingWillEmergeSubscription = animatableProperty.onAnimatorBindingWillEmergeSink(object: object) { [weak self] _ in
            self?.editViewModel = self?.makeEditViewModel()
        }
        
        bindingWillPerishSubscription = animatableProperty.onAnimatorBindingWillPerishSink(object: object, callback: { [weak self] in
            self?.editViewModel = nil
        })
        
        if animatableProperty.isAnimatorBound(object: object) {
            self.editViewModel = makeEditViewModel()
        }
        
        self.actions.append(.init(iconName: "bolt.slash", action: { [weak self] in
            self?.unbindAnimator()
        }))
    }
    
    func bindAnimator(id: SPTAnimatorId) {
        animatableProperty.bindOrUpdate(.init(animatorId: id, valueAt0: -10.0, valueAt1: 10.0), object: object)
    }
    
    func unbindAnimator() {
        animatableProperty.unbindAnimator(object: object)
    }
    
    func makeEditViewModel() -> EditAnimatorBindingViewModel<AP>? {
        nil
    }
    
    override var isSetup: Bool {
        animatableProperty.isAnimatorBound(object: object)
    }
    
    override func accept(_ provider: ComponentViewProvider) -> AnyView? {
        provider.viewFor(self)
    }
    
    override func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        provider.viewFor(self, onComplete: onComplete)
    }
    
}


struct AnimatorBindingComponentView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    
    var body: some View {
        Group {
            if let property = component.selectedProperty, let model = component.editViewModel {
                EditAnimatorBindingView<AP>(property: property, model: model)
            }
        }
        .id(component.id)
    }
    
}


class EditAnimatorBindingViewModel<AP>: ObservableObject where AP: SPTAnimatableProperty {
    
    let animatableProperty: AP
    let object: SPTObject
    
    @SPTObservedAnimatorBinding<AP> var binding: SPTAnimatorBinding
    
    init(animatableProperty: AP, object: SPTObject) {
        self.animatableProperty = animatableProperty
        self.object = object
        
        _binding = .init(property: animatableProperty, object: object)
        _binding.publisher = self.objectWillChange
    }
    
    func onAppear() { }
    
    func onDisappear() { }
}


struct EditAnimatorBindingView<AP>: View where AP: SPTAnimatableProperty {
    
    let property: AnimatorBindingComponentProperty
    @ObservedObject var model: EditAnimatorBindingViewModel<AP>
    
    @State private var scale = FloatSelector.Scale._1
    @State private var isSnappingEnabled = false
    
    var body: some View {
        Group {
            switch property {
            case .animator:
                AnimatorControl(animatorId: $model.binding.animatorId)
            case .valueAt0:
                FloatSelector(value: $model.binding.valueAt0, scale: $scale, isSnappingEnabled: $isSnappingEnabled)
            case .valueAt1:
                FloatSelector(value: $model.binding.valueAt1, scale: $scale, isSnappingEnabled: $isSnappingEnabled)
            }
        }
        .transition(.identity)
        .onAppear {
            model.onAppear()
        }
        .onDisappear {
            model.onDisappear()
        }
    }
    
}
