//
//  LinearPositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.22.
//

import SwiftUI


class LinearPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    typealias FieldComponent = AnimatorBindingSetupComponent<LinearPositionOffsetAnimatorBindingComponent>
    
    lazy private(set) var offset = FieldComponent(animatableProperty: .linearPositionOffset, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [offset] }
    
}


class LinearPositionOffsetAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var lineObject: SPTObject!
    private var point0Object: SPTObject!
    private var point1Object: SPTObject!
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        setupLine()
        setupPoints()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(lineObject)
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
    }
    
    private func setupLine() {
        let position = SPTPosition.get(object: object)
        
        guard position.coordinateSystem == .linear else { fatalError() }
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: position.linear.origin), object: lineObject)
        SPTScale.make(.init(x: 500.0), object: lineObject)
        
        // Make sure up and direction vectors are not collinear for correct line orientation
        let up: simd_float3 = SPTCollinear(position.linear.direction, .up, 0.0001) ? .left : .up
        SPTOrientation.make(.init(lookAt: .init(target: position.linear.origin + position.linear.direction, up: up, axis: .X, positive: true)), object: lineObject)
        SPTPolylineLookDepthBiasMake(lineObject, 5.0, 3.0, 0.0)
    }
    
    private func setupPoints() {
        
        point0Object = sceneViewModel.scene.makeObject()
        var p0Pos = SPTPosition.get(object: object)
        p0Pos.linear.offset += binding.valueAt0
        SPTPosition.make(p0Pos, object: point0Object)
        
        point1Object = sceneViewModel.scene.makeObject()
        var p1Pos = SPTPosition.get(object: object)
        p1Pos.linear.offset += binding.valueAt1
        SPTPosition.make(p1Pos, object: point1Object)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [unowned self] newValue in
            
            var p0Pos = SPTPosition.get(object: object)
            p0Pos.linear.offset += newValue.valueAt0
            SPTPosition.update(p0Pos, object: point0Object)
            
            var p1Pos = SPTPosition.get(object: object)
            p1Pos.linear.offset += newValue.valueAt1
            SPTPosition.update(p1Pos, object: point1Object)
        })
        
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    static var defaultValueAt0: Float { -5 }
    
    static var defaultValueAt1: Float { 5 }
    
}


struct LinearPositionOffsetAnimatorBindingComponentView: View {
    
    @ObservedObject var component: LinearPositionOffsetAnimatorBindingComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0, scale: $editingParams[linearPositionBindingOf: component.object].offset.valueAt0.scale, isSnappingEnabled: $editingParams[linearPositionBindingOf: component.object].offset.valueAt0.isSnapping) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color.secondaryLightSelectionColor)
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1, scale: $editingParams[linearPositionBindingOf: component.object].offset.valueAt1.scale, isSnappingEnabled: $editingParams[linearPositionBindingOf: component.object].offset.valueAt1.isSnapping) { editingState in
                   userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color.secondaryLightSelectionColor)
            case .none:
                EmptyView()
            }
        }
        .transition(.identity)
    }
    
}
