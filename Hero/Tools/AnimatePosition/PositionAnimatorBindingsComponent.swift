//
//  PositionAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI
import Combine


class PositionAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel

    typealias FieldComponent = AnimatorBindingSetupComponent<PositionFieldAnimatorBindingComponent>
    
    lazy private(set) var x = FieldComponent(animatableProperty: .cartesianPositionX, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = FieldComponent(animatableProperty: .cartesianPositionY, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = FieldComponent(animatableProperty: .cartesianPositionZ, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
}


class PositionFieldAnimatorBindingComponent: AnimatorBindingComponentBase<SPTAnimatableObjectProperty>, AnimatorBindingComponentProtocol {
    
    private var guideObjects: (point0: SPTObject, point1: SPTObject, line: SPTObject)?
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        super.init(animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
    }
    
    override var selectedProperty: AnimatorBindingComponentProperty? {
        didSet {
            if isActive {
                
                var point0Look = SPTPointLook.get(object: guideObjects!.point0)
                point0Look.color = Self.guidePoint0Color(selectedProperty: selectedProperty!).rgba
                SPTPointLook.update(point0Look, object: guideObjects!.point0)
                
                var point1Look = SPTPointLook.get(object: guideObjects!.point1)
                point1Look.color = Self.guidePoint1Color(selectedProperty: selectedProperty!).rgba
                SPTPointLook.update(point1Look, object: guideObjects!.point1)
                
            }
        }
    }
    
    override func onActive() {
        setupGuideObjects()
    }
    
    override func onInactive() {
        removeGuideObjects()
    }
    
    private func setupGuideObjects() {

        guideObjects = (sceneViewModel.scene.makeObject(), sceneViewModel.scene.makeObject(), sceneViewModel.scene.makeObject())
        
        let pointSize: Float = 6.0
        
        SPTPosition.make(guidePoint0Position, object: guideObjects!.point0)
        SPTPointLook.make(.init(color: Self.guidePoint0Color(selectedProperty: selectedProperty).rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point0)
        
        SPTPosition.make(guidePoint1Position, object: guideObjects!.point1)
        SPTPointLook.make(.init(color: Self.guidePoint1Color(selectedProperty: selectedProperty).rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point1)
        
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.line)
        SPTScale.make(guideLineScale, object: guideObjects!.line)
        SPTPosition.make(guideLinePosition, object: guideObjects!.line)
        SPTPolylineLookDepthBiasMake(guideObjects!.line, 5.0, 3.0, 0.0)
        switch animatableProperty {
        case .cartesianPositionX:
            break
        case .cartesianPositionY:
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ)), object: guideObjects!.line)
        case .cartesianPositionZ:
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: guideObjects!.line)
        default:
            fatalError()
        }
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [weak self] newValue in

            guard let weakSelf = self, let guideObjects = weakSelf.guideObjects else { return }

            SPTPosition.update(weakSelf.guidePoint0Position, object: guideObjects.point0)

            SPTPosition.update(weakSelf.guidePoint1Position, object: guideObjects.point1)

            SPTScale.update(weakSelf.guideLineScale, object: guideObjects.line)
            SPTPosition.update(weakSelf.guideLinePosition, object: guideObjects.line)

        })
        
    }
    
    private var guideLineScale: SPTScale {
        .init(x: 0.5 * abs(binding.valueAt1 - binding.valueAt0), y: 1.0, z: 1.0)
    }
    
    private var guideLinePosition: SPTPosition {
        var xyz = objectPositionXYZ
        xyz[fieldIndex] += 0.5 * (binding.valueAt0 + binding.valueAt1)
        return .init(cartesian: xyz)
    }
    
    private var guidePoint0Position: SPTPosition {
        var xyz = objectPositionXYZ
        xyz[fieldIndex] += binding.valueAt0
        return .init(cartesian: xyz)
    }
    
    private var guidePoint1Position: SPTPosition {
        var xyz = objectPositionXYZ
        xyz[fieldIndex] += binding.valueAt1
        return .init(cartesian: xyz)
    }
    
    static private func guidePoint0Color(selectedProperty: AnimatorBindingComponentProperty?) -> UIColor {
        if selectedProperty == .valueAt0 {
            return .secondaryLightSelectionColor
        }
        return .secondarySelectionColor
    }
 
    static private func guidePoint1Color(selectedProperty: AnimatorBindingComponentProperty?) -> UIColor {
        if selectedProperty == .valueAt1 {
            return .secondaryLightSelectionColor
        }
        return .secondarySelectionColor
    }
    
    var fieldIndex: Int {
        switch animatableProperty {
        case .cartesianPositionX:
            return 0
        case .cartesianPositionY:
            return 1
        case .cartesianPositionZ:
            return 2
        default:
            fatalError()
        }
    }
    
    private func removeGuideObjects() {
        guard let objects = guideObjects else { return }
        SPTSceneProxy.destroyObject(objects.point0)
        SPTSceneProxy.destroyObject(objects.point1)
        SPTSceneProxy.destroyObject(objects.line)
        guideObjects = nil
        bindingWillChangeSubscription = nil
    }
    
    private var objectPositionXYZ: simd_float3 {
        SPTPosition.get(object: object).cartesian
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    static var defaultValueAt0: Float { -5 }
    
    static var defaultValueAt1: Float { 5 }
    
}


struct PositionFieldAnimatorBindingView: View {
    
    @ObservedObject var component: PositionFieldAnimatorBindingComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .animator:
                AnimatorControl(animatorId: $component.binding.animatorId)
                    .tint(Color.primarySelectionColor)
            case .valueAt0:
                FloatSelector(value: $component.binding.valueAt0, scale: $editingParams[positionBindingOf: component.object].valueAt0.scale, isSnappingEnabled: $editingParams[positionBindingOf: component.object].valueAt0.isSnapping) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
                .tint(Color.secondaryLightSelectionColor)
            case .valueAt1:
                FloatSelector(value: $component.binding.valueAt1, scale: $editingParams[positionBindingOf: component.object].valueAt1.scale, isSnappingEnabled: $editingParams[positionBindingOf: component.object].valueAt1.isSnapping) { editingState in
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
