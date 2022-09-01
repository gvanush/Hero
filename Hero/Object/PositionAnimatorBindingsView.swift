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
    
    private var guideObjects: (point0: SPTObject, point1: SPTObject, line: SPTObject)?
    private var objectInitialPosition: SPTPosition?
    private var bindingWillChangeSubscription: SPTAnySubscription?
    
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
        
        super.init(animatableProperty: animatableProperty, title: axis.displayName, object: object, parent: parent)
    }
    
    override func onActive() {
        objectInitialPosition = SPTPosition.get(object: object)
        setupGuideObjects()
    }
    
    override func onInactive() {
        removeGuideObjects()
        SPTPosition.update(objectInitialPosition!, object: object)
        objectInitialPosition = nil
    }
        
    private func setupGuideObjects() {
        
        guideObjects = (sceneViewModel.scene.makeObject(), sceneViewModel.scene.makeObject(), sceneViewModel.scene.makeObject())
        
        let pointSize: Float = 6.0
        
        SPTPosition.make(guidePoint0Position, object: guideObjects!.point0)
        SPTPointLook.make(.init(color: UIColor.yellow.rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point0)
        
        SPTPosition.make(guidePoint1Position, object: guideObjects!.point1)
        SPTPointLook.make(.init(color: UIColor.yellow.rgba, size: pointSize, categories: LookCategories.toolGuide.rawValue), object: guideObjects!.point1)
        
        SPTPolylineViewMake(guideObjects!.line, sceneViewModel.lineMeshId, UIColor.objectSelectionColor.rgba, 3.0)
        SPTScale.make(guideLineScale, object: guideObjects!.line)
        SPTPosition.make(guideLinePosition, object: guideObjects!.line)
        SPTPolylineViewDepthBiasMake(guideObjects!.line, 5.0, 3.0, 0.0)
        switch axis {
        case .x:
            break
        case .y:
            SPTOrientationMakeEuler(guideObjects!.line, .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ))
        case .z:
            SPTOrientationMakeEuler(guideObjects!.line, .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ))
        }
        
        SPTPosition.update(objectPosition, object: object)
        
        bindingWillChangeSubscription = animatableProperty.onAnimatorBindingWillChangeSink(object: object, callback: { [weak self] newValue in
            
            guard let weakSelf = self, let guideObjects = weakSelf.guideObjects else { return }
            
            SPTPosition.update(weakSelf.guidePoint0Position, object: guideObjects.point0)
            
            SPTPosition.update(weakSelf.guidePoint1Position, object: guideObjects.point1)
            
            SPTScale.update(weakSelf.guideLineScale, object: guideObjects.line)
            SPTPosition.update(weakSelf.guideLinePosition, object: guideObjects.line)
            
            SPTPosition.update(weakSelf.objectPosition, object: weakSelf.object)
        })
        
    }
    
    override var animatorValue: Float {
        didSet {
            SPTPosition.update(objectPosition, object: object)
        }
    }
    
    private var objectPosition: SPTPosition {
        var xyz = objectInitialPosition!.xyz
        xyz[axis.rawValue] = valueAt0 + animatorValue * (valueAt1 - valueAt0)
        return .init(xyz: xyz)
    }
    
    private var guideLineScale: SPTScale {
        .init(x: 0.5 * abs(valueAt1 - valueAt0), y: 1.0, z: 1.0)
    }
    
    private var guideLinePosition: SPTPosition {
        var xyz = objectInitialPosition!.xyz
        xyz[axis.rawValue] += 0.5 * (valueAt0 + valueAt1)
        return .init(xyz: xyz)
    }
    
    private var guidePoint0Position: SPTPosition {
        var xyz = objectInitialPosition!.xyz
        xyz[axis.rawValue] += valueAt0
        return .init(xyz: xyz)
    }
    
    private var guidePoint1Position: SPTPosition {
        var xyz = objectInitialPosition!.xyz
        xyz[axis.rawValue] += valueAt1
        return .init(xyz: xyz)
    }
 
    private func removeGuideObjects() {
        guard let objects = guideObjects else { return }
        SPTScene.destroy(objects.point0)
        SPTScene.destroy(objects.point1)
        SPTScene.destroy(objects.line)
        guideObjects = nil
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


struct PositionAnimatorBindingsView: View {
    
    @ObservedObject var component: PositionAnimatorBindingsComponent
    @Binding var editedComponent: Component?
    
    var body: some View {
        Form {
            Section("X") {
                AnimatorBindingComponentView(component: component.x, editedComponent: $editedComponent)
            }
            Section("Y") {
                AnimatorBindingComponentView(component: component.y, editedComponent: $editedComponent)
            }
            Section("Z") {
                AnimatorBindingComponentView(component: component.z, editedComponent: $editedComponent)
            }
        }
        .navigationTitle("Position Animators")
    }
}
