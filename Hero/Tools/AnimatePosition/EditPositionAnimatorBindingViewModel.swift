//
//  EditPositionAnimatorBindingViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.10.22.
//

import Foundation
import Combine

class EditPositionAnimatorBindingViewModel: EditAnimatorBindingViewModel<SPTAnimatableObjectProperty> {
    
    let axis: Axis
    let sceneViewModel: SceneViewModel
    
    private var guideObjects: (point0: SPTObject, point1: SPTObject, line: SPTObject)?
    private var bindingWillChangeSubscription: SPTAnySubscription?
    private var selectedPropertySubscription: AnyCancellable?
    
    init(editingParams: EditingParams, axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel) {
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
        
        super.init(editingParams: editingParams, animatableProperty: animatableProperty, object: object)
        
        selectedPropertySubscription = self.$selectedProperty.sink { [weak self] newValue in
            guard let property = newValue, let self = self, let guideObjects = self.guideObjects else {
                return
            }
            
            var point0Look = SPTPointLook.get(object: guideObjects.point0)
            point0Look.color = Self.guidePoint0Color(selectedProperty: property).rgba
            SPTPointLook.update(point0Look, object: guideObjects.point0)
            
            var point1Look = SPTPointLook.get(object: guideObjects.point1)
            point1Look.color = Self.guidePoint1Color(selectedProperty: property).rgba
            SPTPointLook.update(point1Look, object: guideObjects.point1)
        }
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
        SPTPointLook.make(.init(color: Self.guidePoint0Color(selectedProperty: selectedProperty).rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point0)
        
        SPTPosition.make(guidePoint1Position, object: guideObjects!.point1)
        SPTPointLook.make(.init(color: Self.guidePoint1Color(selectedProperty: selectedProperty).rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point1)
        
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.line)
        SPTScale.make(guideLineScale, object: guideObjects!.line)
        SPTPosition.make(guideLinePosition, object: guideObjects!.line)
        SPTPolylineLookDepthBiasMake(guideObjects!.line, 5.0, 3.0, 0.0)
        switch axis {
        case .x:
            break
        case .y:
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ)), object: guideObjects!.line)
        case .z:
            SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: guideObjects!.line)
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
