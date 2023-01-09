//
//  EulerOrientationFieldAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.23.
//

import Foundation
import SwiftUI


class EulerOrientationFieldAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private let fieldKeyPath: WritableKeyPath<SPTOrientation, Float>
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var guideObject: SPTObject!
    private var lineObject: SPTObject!
    
    fileprivate let editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>
    
    required override init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        switch animatableProperty {
        case .eulerOrientationX:
            fieldKeyPath = \.euler.x
            editingParamsKeyPath = \.[eulerOrientationBindingOf: object].x
        case .eulerOrientationY:
            fieldKeyPath = \.euler.y
            editingParamsKeyPath = \.[eulerOrientationBindingOf: object].y
        case .eulerOrientationZ:
            fieldKeyPath = \.euler.z
            editingParamsKeyPath = \.[eulerOrientationBindingOf: object].z
        default:
            fatalError()
        }
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: lineObject)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: lineObject)
        
        let orientation = SPTOrientation.get(object: object)
        
        switch animatableProperty {
        case .eulerOrientationX:
            SPTScale.make(.init(x: 500.0), object: lineObject)
            
            switch orientation.model {
            case .eulerXYZ:
                SPTOrientation.make(.init(eulerX: 0.0, y: orientation.euler.y, z: orientation.euler.z), object: lineObject)
            case .eulerXZY:
                SPTOrientation.make(.init(eulerX: 0.0, z: orientation.euler.z, y: orientation.euler.y), object: lineObject)
            case .eulerYXZ:
                SPTOrientation.make(.init(eulerY: 0.0, x: 0.0, z: orientation.euler.z), object: lineObject)
            case .eulerZXY:
                SPTOrientation.make(.init(eulerZ: 0.0, x: 0.0, y: orientation.euler.y), object: lineObject)
            case .eulerYZX, .eulerZYX:
                break
            default:
                fatalError()
            }
            
        case .eulerOrientationY:
            SPTScale.make(.init(y: 500.0), object: lineObject)
            
            switch orientation.model {
            case .eulerXYZ:
                SPTOrientation.make(.init(eulerX: 0.0, y: 0.0, z: orientation.euler.z), object: lineObject)
            case .eulerYXZ:
                SPTOrientation.make(.init(eulerY: 0.0, x: orientation.euler.x, z: orientation.euler.z), object: lineObject)
            case .eulerYZX:
                SPTOrientation.make(.init(eulerY: 0.0, z: orientation.euler.z, x: orientation.euler.x), object: lineObject)
            case .eulerZYX:
                SPTOrientation.make(.init(eulerZ: 0.0, y: 0.0, x: orientation.euler.x), object: lineObject)
            case .eulerXZY, .eulerZXY:
                break
            default:
                fatalError()
            }
            
        case .eulerOrientationZ:
            SPTScale.make(.init(z: 500.0), object: lineObject)
            
            switch orientation.model {
            case .eulerXZY:
                SPTOrientation.make(.init(eulerX: 0.0, z: 0.0, y: orientation.euler.y), object: lineObject)
            case .eulerYZX:
                SPTOrientation.make(.init(eulerY: 0.0, z: 0.0, x: orientation.euler.x), object: lineObject)
            case .eulerZXY:
                SPTOrientation.make(.init(eulerZ: 0.0, x: orientation.euler.x, y: orientation.euler.y), object: lineObject)
            case .eulerZYX:
                SPTOrientation.make(.init(eulerZ: 0.0, y: orientation.euler.y, x: orientation.euler.x), object: lineObject)
            case .eulerXYZ, .eulerYXZ:
                break
            default:
                fatalError()
            }
            
        default:
            fatalError()
        }
        
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
        case .eulerOrientationX:
            lineColor = .xAxisLight
            polylineId = sceneViewModel.xAxisLineMeshId
        case .eulerOrientationY:
            lineColor = .yAxisLight
            polylineId = sceneViewModel.yAxisLineMeshId
        case .eulerOrientationZ:
            lineColor = .zAxisLight
            polylineId = sceneViewModel.zAxisLineMeshId
        default:
            fatalError()
        }
        
        SPTPolylineLook.make(.init(color: lineColor.rgba, polylineId: polylineId, thickness: .guideLineBoldThickness, categories: LookCategories.guide.rawValue), object: lineObject)
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
            updateGuideField(SPTOrientation.get(object: object)[keyPath: fieldKeyPath])
        }
    }
    
    private func updateGuideField(_ value: Float) {
        var orientation = SPTOrientation.get(object: guideObject)
        orientation[keyPath: fieldKeyPath] = value
        SPTOrientation.update(orientation, object: guideObject)
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}


struct EulerOrientationFieldAnimatorBindingComponentView: View {
    
    @ObservedObject var component: EulerOrientationFieldAnimatorBindingComponent
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0InDegrees, scale: editingParamBinding(keyPath: \.valueAt0.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt0.isSnapping), formatter: Formatters.distance) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1InDegrees, scale: editingParamBinding(keyPath: \.valueAt1.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt1.isSnapping), formatter: Formatters.distance) { editingState in
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
