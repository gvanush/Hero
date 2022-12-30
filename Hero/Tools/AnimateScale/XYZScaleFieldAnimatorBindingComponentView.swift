//
//  XYZScaleFieldAnimatorBindingComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import SwiftUI

class XYZScaleFieldAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private let fieldKeyPath: WritableKeyPath<SPTScale, Float>
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var guideObject: SPTObject!
    private var lineObject: SPTObject!
    
    fileprivate let editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>
    
    required override init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        switch animatableProperty {
        case .xyzScaleX:
            fieldKeyPath = \.xyz.x
            editingParamsKeyPath = \.[xyzScaleBindingOf: object].x
        case .xyzScaleY:
            fieldKeyPath = \.xyz.y
            editingParamsKeyPath = \.[xyzScaleBindingOf: object].y
        case .xyzScaleZ:
            fieldKeyPath = \.xyz.z
            editingParamsKeyPath = \.[xyzScaleBindingOf: object].z
        default:
            fatalError()
        }
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: lineObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: lineObject)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: lineObject)
        
    }
    
    deinit {
        SPTSceneProxy.destroyObject(lineObject)
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty {
        didSet {
            if isActive {
                updateFieldValue()
            }
        }
    }
    
    override func onVisible() {
        
        var lineColor: UIColor!
        var polylineId: SPTPolylineId!
        switch animatableProperty {
        case .xyzScaleX:
            lineColor = .xAxisLight
            polylineId = sceneViewModel.xAxisLineMeshId
            SPTScale.make(.init(x: 500.0), object: lineObject)
        case .xyzScaleY:
            lineColor = .yAxisLight
            polylineId = sceneViewModel.yAxisLineMeshId
            SPTScale.make(.init(y: 500.0), object: lineObject)
        case .xyzScaleZ:
            lineColor = .zAxisLight
            polylineId = sceneViewModel.zAxisLineMeshId
            SPTScale.make(.init(z: 500.0), object: lineObject)
        default:
            fatalError()
        }
        
        SPTPolylineLook.make(.init(color: lineColor.rgba, polylineId: polylineId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: lineObject)
    }
    
    override func onInvisible() {
        SPTPolylineLook.destroy(object: lineObject)
        SPTScale.destroy(object: lineObject)
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
        
        var outlineLook = SPTOutlineLook.get(object: object)
        SPTOutlineLook.make(outlineLook, object: guideObject)
        
        outlineLook.categories &= ~LookCategories.guide.rawValue
        SPTOutlineLook.update(outlineLook, object: object)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingDidChangeSink(object: object, callback: { [unowned self] newValue in
            self.updateFieldValue()
        })
        
        updateFieldValue()
    }
    
    override func onInactive() {
        var meshLook = SPTMeshLook.get(object: object)
        meshLook.categories |= LookCategories.renderableModel.rawValue
        SPTMeshLook.update(meshLook, object: object)
        
        var outlineLook = SPTOutlineLook.get(object: object)
        outlineLook.categories |= LookCategories.guide.rawValue
        SPTOutlineLook.update(outlineLook, object: object)
        
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


struct XYZScaleFieldAnimatorBindingComponentView: View {
    
    @ObservedObject var component: XYZScaleFieldAnimatorBindingComponent
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0, scale: editingParamBinding(keyPath: \.valueAt0.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt0.isSnapping), formatter: Formatters.distance) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1, scale: editingParamBinding(keyPath: \.valueAt1.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt1.isSnapping), formatter: Formatters.distance) { editingState in
                   userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
    func editingParamBinding<T>(keyPath: WritableKeyPath<AnimatorBindingEditingParams, T>) -> Binding<T> {
        _editingParams.projectedValue[dynamicMember: component.editingParamsKeyPath.appending(path: keyPath)]
    }
    
}
