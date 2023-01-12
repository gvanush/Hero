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
    
    let animatableProperty: AnimatorBindingComponent.AP
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let defaultValueAt0: Float
    let defaultValueAt1: Float
    
    @Published var animatorBindingComponent: AnimatorBindingComponent? {
        willSet {
            
            guard animatorBindingComponent != newValue, isAwake else {
                return
            }
            
            if isActive {
                animatorBindingComponent?.deactivate()
            }
            
            newValue?.awake()
            
            if let parent = parent {
                if parent.isDisclosed {
                    newValue?.appear()
                }
            } else {
                newValue?.appear()
            }
            
            if isDisclosed {
                animatorBindingComponent?.close()
                newValue?.disclose()
            }
            
            if let parent = parent {
                if parent.isDisclosed {
                    animatorBindingComponent?.disappear()
                }
            } else {
                animatorBindingComponent?.disappear()
            }
            
            animatorBindingComponent?.sleep()
            
            if isActive {
                newValue?.activate()
            }
        }
    }
    
    private var bindingDidEmergeSubscription: SPTAnySubscription?
    private var bindingWillPerishSubscription: SPTAnySubscription?
    private var editViewComponentCancellable: AnyCancellable?
    
    init(animatableProperty: AnimatorBindingComponent.AP, defaultValueAt0: Float, defaultValueAt1: Float, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.animatableProperty = animatableProperty
        self.defaultValueAt0 = defaultValueAt0
        self.defaultValueAt1 = defaultValueAt1
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(parent: parent)
        
        bindingDidEmergeSubscription = animatableProperty.onAnimatorBindingDidEmergeSink(object: object) { [unowned self] _ in
            self.setupAnimatorBindingComponent()
        }
        
        bindingWillPerishSubscription = animatableProperty.onAnimatorBindingWillPerishSink(object: object, callback: { [unowned self] in
            self.animatorBindingComponent = nil
            self.editViewComponentCancellable = nil
        })

        if animatableProperty.isAnimatorBound(object: object) {
            setupAnimatorBindingComponent()
        }
        
    }
    
    override func awake() {
        super.awake()
        animatorBindingComponent?.awake()
    }
    
    override func sleep() {
        animatorBindingComponent?.sleep()
        super.sleep()
    }
    
    override func appear() {
        super.appear()
        animatorBindingComponent?.appear()
    }

    override func disappear() {
        animatorBindingComponent?.disappear()
        super.disappear()
    }
    
    override func disclose() {
        isDisclosed = true
        onDisclose()
        animatorBindingComponent?.disclose()
    }
    
    override func close() {
        animatorBindingComponent?.close()
        onClose()
        isDisclosed = false
    }
    
    override func activate() {
        super.activate()
        animatorBindingComponent?.activate()
    }
    
    override func deactivate() {
        animatorBindingComponent?.deactivate()
        super.deactivate()
    }
    
    private func setupAnimatorBindingComponent() {
        animatorBindingComponent = AnimatorBindingComponent(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: nil)
        editViewComponentCancellable = animatorBindingComponent!.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
        }
    }
    
    override var title: String {
        "\(animatableProperty.displayName)"
    }
    
    func bindAnimator(id: SPTAnimatorId) {
        animatableProperty.bindOrUpdate(.init(animatorId: id, valueAt0: defaultValueAt0, valueAt1: defaultValueAt1), object: object)
    }
    
    func unbindAnimator() {
        animatableProperty.unbindAnimator(object: object)
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
    
    var body: some View {
        Group {
            if let editViewComponent = component.animatorBindingComponent {
                editViewComponent.accept(provider)
                    .id(component.id)
                    .actionBarObjectSection {
                        ActionBarButton(iconName: "bolt.slash") {
                            component.unbindAnimator()
                        }
                        .tag(component.id)
                    }
            }
        }
    }
    
}


