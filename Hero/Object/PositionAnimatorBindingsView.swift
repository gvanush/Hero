//
//  PositionAnimatorBindingsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


class PositionAnimatorBindingComponent: AnimatorBindingComponent<SPTAnimatableObjectProperty> {
    
    let axis: Axis
    let sceneViewModel: SceneViewModel
    
    init(axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.axis = axis
        self.sceneViewModel = sceneViewModel
        
        var animatableProperty: SPTAnimatableObjectProperty!
        switch axis {
        case .x:
            animatableProperty = .positionX
        case .y:
            animatableProperty = .positionY
        case .z:
            animatableProperty = .positionZ
        }
        
        super.init(animatableProperty: animatableProperty, title: "\(axis.displayName) Binding", object: object, parent: parent)
    }
    
    override func makeEditViewModel() -> EditAnimatorBindingViewModel<SPTAnimatableObjectProperty>? {
        EditPositionAnimatorBindingViewModel(axis: axis, object: object, sceneViewModel: sceneViewModel)
    }
}


class EditPositionAnimatorBindingViewModel: EditAnimatorBindingViewModel<SPTAnimatableObjectProperty> {
    
    let axis: Axis
    let sceneViewModel: SceneViewModel
    
    private var guideObjects: (point0: SPTObject, point1: SPTObject, line: SPTObject)?
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
    init(axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel) {
        self.axis = axis
        self.sceneViewModel = sceneViewModel
        
        var animatableProperty: SPTAnimatableObjectProperty!
        switch axis {
        case .x:
            animatableProperty = .positionX
        case .y:
            animatableProperty = .positionY
        case .z:
            animatableProperty = .positionZ
        }
        
        super.init(animatableProperty: animatableProperty, object: object)
    }
    
    override func onAppear() {
        setupGuideObjects()
    }
    
    override func onDisappear() {
        removeGuideObjects()
    }
    
    private func setupGuideObjects() {

        guideObjects = (sceneViewModel.scene.makeObject(), sceneViewModel.scene.makeObject(), sceneViewModel.scene.makeObject())
        
        let pointSize: Float = 6.0
        
        SPTPosition.make(guidePoint0Position, object: guideObjects!.point0)
        SPTPointLook.make(.init(color: UIColor.yellow.rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point0)
        
        SPTPosition.make(guidePoint1Position, object: guideObjects!.point1)
        SPTPointLook.make(.init(color: UIColor.yellow.rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point1)
        
        SPTPolylineLook.make(.init(color: UIColor.objectSelectionColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.line)
        SPTScale.make(guideLineScale, object: guideObjects!.line)
        SPTPosition.make(guideLinePosition, object: guideObjects!.line)
        SPTPolylineLookDepthBiasMake(guideObjects!.line, 5.0, 3.0, 0.0)
        switch axis {
        case .x:
            break
        case .y:
            SPTOrientationMakeEuler(guideObjects!.line, .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ))
        case .z:
            SPTOrientationMakeEuler(guideObjects!.line, .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ))
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
        xyz[axis.rawValue] += 0.5 * (binding.valueAt0 + binding.valueAt1)
        return .init(xyz: xyz)
    }
    
    private var guidePoint0Position: SPTPosition {
        var xyz = objectPositionXYZ
        xyz[axis.rawValue] += binding.valueAt0
        return .init(xyz: xyz)
    }
    
    private var guidePoint1Position: SPTPosition {
        var xyz = objectPositionXYZ
        xyz[axis.rawValue] += binding.valueAt1
        return .init(xyz: xyz)
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
        SPTPosition.get(object: object).xyz
    }
    
}


class PositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    lazy private(set) var x = PositionAnimatorBindingComponent(axis: .x, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = PositionAnimatorBindingComponent(axis: .y, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = PositionAnimatorBindingComponent(axis: .z, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(title: "Animators", parent: parent)
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
}
