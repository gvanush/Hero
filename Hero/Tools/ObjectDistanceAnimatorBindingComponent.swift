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
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
    init(axisDirection: simd_float3, editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.normAxisDirection = simd_normalize(axisDirection)
        self.editingParamsKeyPath = editingParamsKeyPath
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        setupLine()
        setupPoints()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(lineObject)
        SPTSceneProxy.destroyObject(point0Object)
        SPTSceneProxy.destroyObject(point1Object)
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty? {
        didSet {
            if isDisclosed {
                
                var point0Look = SPTPointLook.get(object: point0Object)
                var point1Look = SPTPointLook.get(object: point1Object)
                
                switch selectedProperty {
                case .valueAt0:
                    point0Look.color = UIColor.secondaryLightSelectionColor.rgba
                    point1Look.color = UIColor.secondarySelectionColor.rgba
                    sceneViewModel.focusedObject = point0Object
                case .valueAt1:
                    point0Look.color = UIColor.secondarySelectionColor.rgba
                    point1Look.color = UIColor.secondaryLightSelectionColor.rgba
                    sceneViewModel.focusedObject = point1Object
                case .animator:
                    point0Look.color = UIColor.secondarySelectionColor.rgba
                    point1Look.color = UIColor.secondarySelectionColor.rgba
                    sceneViewModel.focusedObject = object
                case .none:
                    fatalError()
                }
                
                SPTPointLook.update(point0Look, object: point0Object)
                SPTPointLook.update(point1Look, object: point1Object)
            }
        }
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: lineObject)

        let point0Color = (selectedProperty == .valueAt0 ? UIColor.secondaryLightSelectionColor : UIColor.secondarySelectionColor).rgba
        SPTPointLook.make(.init(color: point0Color, size: 6.0, categories: LookCategories.toolGuide.rawValue), object: point0Object)
        
        let point1Color = (selectedProperty == .valueAt1 ? UIColor.secondaryLightSelectionColor : UIColor.secondarySelectionColor).rgba
        SPTPointLook.make(.init(color: point1Color, size: 6.0, categories: LookCategories.toolGuide.rawValue), object: point1Object)
        
        switch selectedProperty {
        case .valueAt0:
            sceneViewModel.focusedObject = point0Object
        case .valueAt1:
            sceneViewModel.focusedObject = point1Object
        case .animator:
            break
        case .none:
            fatalError()
        }
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: lineObject)
        SPTPointLook.destroy(object: point0Object)
        SPTPointLook.destroy(object: point1Object)
        // If this component still 'owns' focused object then revert to the source object otherwise
        // leave as it is. This is relevant when component is closed when entire component tree is removed
        // from the screen
        if sceneViewModel.focusedObject == point0Object || sceneViewModel.focusedObject == point1Object {
            sceneViewModel.focusedObject = self.object
        }
        bindingWillChangeSubscription = nil
    }
    
    private func setupLine() {
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin), object: lineObject)
        SPTScale.make(.init(x: 500.0), object: lineObject)
        
        // Make sure up and direction vectors are not collinear for correct line orientation
        let up: simd_float3 = SPTCollinear(normAxisDirection, .up, 0.0001) ? .left : .up
        SPTOrientation.make(.init(lookAt: .init(target: origin + normAxisDirection, up: up, axis: .X, positive: true)), object: lineObject)
        SPTPolylineLookDepthBiasMake(lineObject, 5.0, 3.0, 0.0)
    }
    
    private func setupPoints() {
        
        point0Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(point0Position, object: point0Object)
        
        point1Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(point1Position, object: point1Object)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [unowned self] newValue in
            SPTPosition.update(point0Position, object: point0Object)
            SPTPosition.update(point1Position, object: point1Object)
        })
        
    }
    
    var point0Position: SPTPosition {
        .init(cartesian: origin + binding.valueAt0 * normAxisDirection)
    }
    
    var point1Position: SPTPosition {
        .init(cartesian: origin + binding.valueAt1 * normAxisDirection)
    }
    
    private var origin: simd_float3 {
        SPTPosition.get(object: object).toCartesian.cartesian
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
                FloatSelector(value: $component.binding.valueAt0, scale: editingParamBinding(keyPath: \.valueAt0.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt0.isSnapping)) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color.secondaryLightSelectionColor)
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1, scale: editingParamBinding(keyPath: \.valueAt1.scale), isSnappingEnabled: editingParamBinding(keyPath: \.valueAt1.isSnapping)) { editingState in
                   userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color.secondaryLightSelectionColor)
            case .none:
                EmptyView()
            }
        }
        .transition(.identity)
    }
 
    func editingParamBinding<T>(keyPath: WritableKeyPath<AnimatorBindingEditingParams, T>) -> Binding<T> {
        _editingParams.projectedValue[dynamicMember: component.editingParamsKeyPath.appending(path: keyPath)]
    }
    
}
