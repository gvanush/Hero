//
//  ObjectAngleAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

import Foundation
import SwiftUI


class ObjectAngleAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty> {
 
    private let origin: simd_float3
    private let normRotationAxis: simd_float3
    fileprivate var editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>
    
    private var point0Object: SPTObject!
    private var point1Object: SPTObject!
    private var arcObject: SPTObject!
    var guideColor: UIColor = .guide1Dark
    var selectedGuideColor: UIColor = .guide1Light
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
    init(origin: simd_float3, normRotationAxis: simd_float3, editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.origin = origin
        self.normRotationAxis = normRotationAxis
        self.editingParamsKeyPath = editingParamsKeyPath
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        setupGuides()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(point0Object)
        SPTSceneProxy.destroyObject(point1Object)
        SPTSceneProxy.destroyObject(arcObject)
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty {
        didSet {
            if isDisclosed {
                
                var point0Look = SPTPointLook.get(object: point0Object)
                var point1Look = SPTPointLook.get(object: point1Object)
                
                switch selectedProperty {
                case .valueAt0:
                    point0Look.color = selectedGuideColor.rgba
                    point1Look.color = guideColor.rgba
                    sceneViewModel.focusedObject = point0Object
                case .valueAt1:
                    point0Look.color = guideColor.rgba
                    point1Look.color = selectedGuideColor.rgba
                    sceneViewModel.focusedObject = point1Object
                case .animator:
                    point0Look.color = guideColor.rgba
                    point1Look.color = guideColor.rgba
                    sceneViewModel.focusedObject = object
                }
                
                SPTPointLook.update(point0Look, object: point0Object)
                SPTPointLook.update(point1Look, object: point1Object)
            }
        }
    }
    
    override func onDisclose() {

        let point0Color = (selectedProperty == .valueAt0 ? selectedGuideColor : guideColor).rgba
        SPTPointLook.make(.init(color: point0Color, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: point0Object)
        
        let point1Color = (selectedProperty == .valueAt1 ? selectedGuideColor : guideColor).rgba
        SPTPointLook.make(.init(color: point1Color, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: point1Object)
        
        switch selectedProperty {
        case .valueAt0:
            sceneViewModel.focusedObject = point0Object
        case .valueAt1:
            sceneViewModel.focusedObject = point1Object
        case .animator:
            break
        }
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: point0Object)
        SPTPointLook.destroy(object: point1Object)
        // If this component still 'owns' focused object then revert to the source object otherwise
        // leave as it is. This is relevant when component is closed when entire component tree is removed
        // from the screen
        if sceneViewModel.focusedObject == point0Object || sceneViewModel.focusedObject == point1Object {
            sceneViewModel.focusedObject = self.object
        }
    }
 
    override func onVisible() {
        
        let objectPosVec = SPTPosition.get(object: object).toCartesian.cartesian - origin
        let arcRadius = simd_length(objectPosVec)
        
        SPTArcLook.make(.init(color: guideColor.rgba, radius: arcRadius, startAngle: binding.valueAt0, endAngle: binding.valueAt1, thickness: .guideLineBoldThickness), object: arcObject)
        
        let orthoNormal = SPTMatrix3x3.createOrthonormal(normDirection: normRotationAxis, axis: .X)
        let orthoNormalTranspose = simd_transpose(orthoNormal)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [unowned self] newValue in

            let p0 = orthoNormal * SPTMatrix3x3.createEulerRotationX(newValue.valueAt0) * orthoNormalTranspose * objectPosVec
            SPTPosition.update(.init(cartesian: origin + p0), object: point0Object)
            
            let p1 = orthoNormal * SPTMatrix3x3.createEulerRotationX(newValue.valueAt1) * orthoNormalTranspose * objectPosVec
            SPTPosition.update(.init(cartesian: origin + p1), object: point1Object)

            SPTArcLook.update(.init(color: guideColor.rgba, radius: arcRadius, startAngle: newValue.valueAt0, endAngle: newValue.valueAt1, thickness: .guideLineBoldThickness), object: arcObject)
        })
        
    }
    
    override func onInvisible() {
        SPTArcLook.destroy(object: arcObject)
        bindingWillChangeSubscription = nil
    }
    
    private func setupGuides() {
        
        let objectPosVec = SPTPosition.get(object: object).toCartesian.cartesian - origin
        let orthoNormal = SPTMatrix3x3.createOrthonormal(normDirection: normRotationAxis, axis: .X)
        let orthoNormalTranspose = simd_transpose(orthoNormal)
        
        let p0 = orthoNormal * SPTMatrix3x3.createEulerRotationX(binding.valueAt0) * orthoNormalTranspose * objectPosVec
        
        point0Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin + p0), object: point0Object)

        let p1 = orthoNormal * SPTMatrix3x3.createEulerRotationX(binding.valueAt1) * orthoNormalTranspose * objectPosVec
        
        point1Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin + p1), object: point1Object)

        arcObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin), object: arcObject)
        SPTOrientation.make(.init(orthoNormZ: normRotationAxis, orthoNormX: simd_normalize(objectPosVec)), object: arcObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer3, object: arcObject)
        
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    static var defaultValueAt0: Float { -0.25 * .pi }
    
    static var defaultValueAt1: Float { 0.25 * .pi }
    
}


struct AngleAnimatorBindingComponentView: View {
    
    @ObservedObject var component: ObjectAngleAnimatorBindingComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0InDegrees, scale: editingParamBinding(keyPath: \.valueAt0.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt0.isSnapping), formatter: Formatters.angle) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color(uiColor: component.selectedGuideColor))
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1InDegrees, scale: editingParamBinding(keyPath: \.valueAt1.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt1.isSnapping), formatter: Formatters.angle) { editingState in
                   userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color(uiColor: component.selectedGuideColor))
            }
        }
        .transition(.identity)
    }
 
    func editingParamBinding<T>(keyPath: WritableKeyPath<AnimatorBindingEditingParams, T>) -> Binding<T> {
        _editingParams.projectedValue[dynamicMember: component.editingParamsKeyPath.appending(path: keyPath)]
    }
    
}
