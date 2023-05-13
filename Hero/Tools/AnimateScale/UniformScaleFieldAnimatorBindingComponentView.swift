//
//  UniformScaleFieldAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import SwiftUI

class UniformScaleFieldAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var guideObject: SPTObject!
    private let fieldKeyPath: WritableKeyPath<SPTScale, Float>
    
    required override init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        switch animatableProperty {
        case .uniformScale:
            fieldKeyPath = \.uniform
        default:
            fatalError()
        }
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty {
        didSet {
            if isActive {
                updateFieldValue()
            }
        }
    }
    
    override func onActive() {
        
        guideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guideObject)
        SPTScale.make(SPTScale.get(object: object), object: guideObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: guideObject)
        
        var meshLook = SPTMeshLook.get(object: object)
        meshLook.categories &= ~LookCategories.renderableModel.rawValue
        SPTMeshLook.update(meshLook, object: object)
        
        meshLook.categories = LookCategories.guide.rawValue
        SPTMeshLook.make(meshLook, object: guideObject)
        
        if var outlineLook = SPTOutlineLook.tryGet(object: object) {
            SPTOutlineLook.make(outlineLook, object: guideObject)
            
            outlineLook.categories &= ~LookCategories.guide.rawValue
            SPTOutlineLook.update(outlineLook, object: object)
        }
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingDidChangeSink(object: object, callback: { [unowned self] newValue in
            self.updateFieldValue()
        })
        
        updateFieldValue()
    }
    
    override func onInactive() {
        var meshLook = SPTMeshLook.get(object: object)
        meshLook.categories |= LookCategories.renderableModel.rawValue
        SPTMeshLook.update(meshLook, object: object)
        
        if var outlineLook = SPTOutlineLook.tryGet(object: object) {
            outlineLook.categories |= LookCategories.guide.rawValue
            SPTOutlineLook.update(outlineLook, object: object)
        }
        
        bindingWillChangeSubscription = nil
        SPTSceneProxy.destroyObject(guideObject)
    }
    
    private func updateFieldValue() {
        switch selectedProperty {
        case .valueAt0:
            updateGuideField(self.binding.valueAt0)
        case .valueAt1:
            updateGuideField(self.binding.valueAt1)
        case .animator:
            updateGuideField(SPTScale.get(object: object)[keyPath: fieldKeyPath])
        }
    }
    
    private func updateGuideField(_ value: Float) {
        var scale = SPTScale.get(object: guideObject)
        scale[keyPath: fieldKeyPath] = value
        SPTScale.update(scale, object: guideObject)
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}

struct UniformScaleFieldAnimatorBindingComponentView: View {
    
    @ObservedObject var component: UniformScaleFieldAnimatorBindingComponent
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0, scale: editingParam(\.valueAt0).scale, isSnappingEnabled: editingParam(\.valueAt0).isSnapping, formatter: Formatters.distance) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1, scale: editingParam(\.valueAt1).scale, isSnappingEnabled: editingParam(\.valueAt1).isSnapping, formatter: Formatters.distance) { editingState in
                   userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
    func editingParam(_ keyPath: KeyPath<SPTAnimatorBinding, Float>) -> Binding<ObjectPropertyFloatEditingParams> {
        $editingParams[floatPropertyId: SPTAnimatorBindingPropertyId(animatableProperty: component.animatableProperty, propertyKeyPath: keyPath), component.object]
    }
    
}
