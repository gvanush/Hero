//
//  AnimatorBindingSetupComponentView.swift
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


class AnimatorBindingSetupComponent<AnimatorBindingComponent>: Component where AnimatorBindingComponent: Component & AnimatorBindingComponentProtocol {
    
    let initialEditingParams: AnimatorBindingComponent.EditingParams
    let animatableProperty: AnimatorBindingComponent.AP
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @Published var animatorBindingComponent: AnimatorBindingComponent?
    
    private var bindingWillEmergeSubscription: SPTAnySubscription?
    private var bindingWillPerishSubscription: SPTAnySubscription?
    private var editViewComponentCancellable: AnyCancellable?
    
    init(initialEditingParams: AnimatorBindingComponent.EditingParams, animatableProperty: AnimatorBindingComponent.AP, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.initialEditingParams = initialEditingParams
        self.animatableProperty = animatableProperty
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(parent: parent)
        
        bindingWillEmergeSubscription = animatableProperty.onAnimatorBindingWillEmergeSink(object: object) { [weak self] _ in
            self?.setupEditViewModel()
        }
        
        bindingWillPerishSubscription = animatableProperty.onAnimatorBindingWillPerishSink(object: object, callback: { [weak self] in
            self?.animatorBindingComponent = nil
            self?.editViewComponentCancellable = nil
        })
        
        if animatableProperty.isAnimatorBound(object: object) {
            setupEditViewModel()
        }
        
    }
    
    private func setupEditViewModel() {
        animatorBindingComponent = AnimatorBindingComponent(editingParams: initialEditingParams, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: nil)
        editViewComponentCancellable = animatorBindingComponent!.objectWillChange.sink { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    override var title: String {
        "\(animatableProperty.displayName)"
    }
    
    func bindAnimator(id: SPTAnimatorId) {
        animatableProperty.bindOrUpdate(.init(animatorId: id, valueAt0: AnimatorBindingComponent.defaultValueAt0, valueAt1: AnimatorBindingComponent.defaultValueAt1), object: object)
    }
    
    func unbindAnimator() {
        animatableProperty.unbindAnimator(object: object)
    }
    
    var editingParams: AnimatorBindingComponent.EditingParams {
        animatorBindingComponent?.editingParams ?? initialEditingParams
    }
    
    override var isSetup: Bool {
        animatableProperty.isAnimatorBound(object: object)
    }
    
    override var selectedPropertyIndex: Int? {
        get {
            animatorBindingComponent?.selectedPropertyIndex
        }
        set {
            animatorBindingComponent?.selectedPropertyIndex = newValue
        }
    }
    
    override var properties: [String]? {
        animatorBindingComponent?.properties
    }
    
    override var subcomponents: [Component]? {
        animatorBindingComponent?.subcomponents
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    override func accept(_ provider: ComponentSetupViewProvider, onComplete: @escaping () -> Void) -> AnyView {
        provider.viewFor(self, onComplete: onComplete)
    }
    
}


struct AnimatorBindingSetupComponentView<AnimatorBindingComponent, RC>: View where AnimatorBindingComponent: Component & AnimatorBindingComponentProtocol {
    
    @ObservedObject var component: AnimatorBindingSetupComponent<AnimatorBindingComponent>
    let provider: ComponentViewProvider<RC>
    
    @EnvironmentObject private var actionBarModel: ActionBarModel
    
    var body: some View {
        Group {
            if let editViewComponent = component.animatorBindingComponent {
                editViewComponent.accept(provider)
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
    }
    
}


