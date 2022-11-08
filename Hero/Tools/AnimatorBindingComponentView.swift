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
    
    init(animatableProperty: AP, object: SPTObject, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.object = object
        
        super.init(selectedProperty: .valueAt0, parent: parent)
        
        bindingWillEmergeSubscription = animatableProperty.onAnimatorBindingWillEmergeSink(object: object) { [weak self] _ in
            self?.setupEditViewModel()
        }
        
        bindingWillPerishSubscription = animatableProperty.onAnimatorBindingWillPerishSink(object: object, callback: { [weak self] in
            self?.editViewModel = nil
        })
        
        if animatableProperty.isAnimatorBound(object: object) {
            setupEditViewModel()
        }
        
    }
    
    private func setupEditViewModel() {
        self.editViewModel = makeEditViewModel()
        self.editViewModel?.selectedProperty = selectedProperty
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
    
    override var selectedProperty: AnimatorBindingComponentProperty? {
        willSet {
            editViewModel?.selectedProperty = newValue
        }
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    override func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        provider.viewFor(self, onComplete: onComplete)
    }
    
}


struct AnimatorBindingComponentView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var component: AnimatorBindingComponent<AP>
    @EnvironmentObject var actionBarModel: ActionBarModel
    
    var body: some View {
        Group {
            if let model = component.editViewModel {
                EditAnimatorBindingView<AP>(model: model)
            }
        }
        .id(component.id)
        .actionBarObjectSection {
            ActionBarButton(iconName: "bolt.slash") {
                component.unbindAnimator()
            }
        }
        .onAppear {
            actionBarModel.scrollToObjectSection()
        }
    }
    
}


class EditAnimatorBindingViewModel<AP>: ObservableObject where AP: SPTAnimatableProperty {
    
    struct EditingParams {
        var value0 = FloatPropertyEditingParams()
        var value1 = FloatPropertyEditingParams()
    }

    let animatableProperty: AP
    let object: SPTObject
    
    @SPTObservedAnimatorBinding<AP> var binding: SPTAnimatorBinding
    @Published var editingParams: EditingParams
    @Published fileprivate(set) var selectedProperty: AnimatorBindingComponentProperty?
    
    init(editingParams: EditingParams, animatableProperty: AP, object: SPTObject) {
        self.animatableProperty = animatableProperty
        self.object = object
        self.editingParams = editingParams
        
        _binding = .init(property: animatableProperty, object: object)
        _binding.publisher = self.objectWillChange
    }
    
    func onAppear() { }
    
    func onDisappear() { }
}


struct EditAnimatorBindingView<AP>: View where AP: SPTAnimatableProperty {
    
    @ObservedObject var model: EditAnimatorBindingViewModel<AP>
    
    var body: some View {
        Group {
            switch model.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $model.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSelector(value: $model.binding.valueAt0, scale: $model.editingParams.value0.scale, isSnappingEnabled: $model.editingParams.value0.isSnapping)
                    .tint(Color.secondaryLightSelectionColor)
            case .valueAt1:
                FloatSelector(value: $model.binding.valueAt1, scale: $model.editingParams.value1.scale, isSnappingEnabled: $model.editingParams.value1.isSnapping)
                    .tint(Color.secondaryLightSelectionColor)
            case .none:
                EmptyView()
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
