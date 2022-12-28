//
//  ObjectDistanceAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.22.
//

import SwiftUI


class ObjectDistanceAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty> {
    
    private let normAxisDirection: simd_float3
    fileprivate var editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>
    
    private var lineObject: SPTObject!
    private var point0Object: SPTObject!
    private var point1Object: SPTObject!
    var guideColor: UIColor = .guide1Dark
    var selectedGuideColor: UIColor = .guide1Light
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
    init(normAxisDirection: simd_float3, editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.normAxisDirection = normAxisDirection
        self.editingParamsKeyPath = editingParamsKeyPath
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        setupGuides()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(lineObject)
        SPTSceneProxy.destroyObject(point0Object)
        SPTSceneProxy.destroyObject(point1Object)
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
        SPTPolylineLook.make(.init(color: guideColor.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineBoldThickness, categories: LookCategories.guide.rawValue), object: lineObject)
    }
    
    override func onInvisible() {
        SPTPolylineLook.destroy(object: lineObject)
    }
    
    private func setupGuides() {
        
        let origin = SPTPosition.get(object: object).toCartesian.cartesian
        let point0Position = SPTPosition(cartesian: origin + binding.valueAt0 * normAxisDirection)
        let point1Position = SPTPosition(cartesian: origin + binding.valueAt1 * normAxisDirection)
        
        point0Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(point0Position, object: point0Object)
        
        point1Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(point1Position, object: point1Object)
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: 0.5 * (point0Position.cartesian + point1Position.cartesian)), object: lineObject)
        SPTScale.make(.init(x: 0.5 * (binding.valueAt1 - binding.valueAt0)), object: lineObject)
        // Make sure up and direction vectors are not collinear for correct line orientation
        let up: simd_float3 = SPTVector.collinear(normAxisDirection, .up, tolerance: 0.0001) ? .left : .up
        SPTOrientation.make(.init(normDirection: normAxisDirection, up: up, axis: .X), object: lineObject)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: lineObject)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [unowned self] newValue in
            
            let point0Position = SPTPosition(cartesian: origin + newValue.valueAt0 * normAxisDirection)
            let point1Position = SPTPosition(cartesian: origin + newValue.valueAt1 * normAxisDirection)
            
            SPTPosition.update(point0Position, object: point0Object)
            SPTPosition.update(point1Position, object: point1Object)
            
            SPTPosition.update(.init(cartesian: 0.5 * (point0Position.cartesian + point1Position.cartesian)), object: lineObject)
            SPTScale.update(.init(x: 0.5 * (newValue.valueAt1 - newValue.valueAt0)), object: lineObject)
        })
        
    }
 
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    static var defaultValueAt0: Float { -5 }
    
    static var defaultValueAt1: Float { 5 }
    
}


struct DistanceAnimatorBindingComponentView: View {
    
    @ObservedObject var component: ObjectDistanceAnimatorBindingComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0, scale: editingParamBinding(keyPath: \.valueAt0.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt0.isSnapping), formatter: Formatters.distance) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color(uiColor: component.selectedGuideColor))
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1, scale: editingParamBinding(keyPath: \.valueAt1.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt1.isSnapping), formatter: Formatters.distance) { editingState in
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
