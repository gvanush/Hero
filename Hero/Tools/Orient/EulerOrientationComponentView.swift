//
//  EulerOrientationComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.01.23.
//

import SwiftUI

class EulerOrientationComponent: BasicComponent<Axis> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let angleFormatter = Formatters.angle
    
    @SPTObservedComponent private var orientation: SPTOrientation
    
    private var guideObject: SPTObject?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _orientation = .init(object: object)
        
        super.init(selectedProperty: .z, parent: parent)
        
        _orientation.publisher = self.objectWillChange
        
        switch orientation.model {
        case .eulerXYZ, .eulerXZY:
            selectedProperty = .x
        case .eulerYXZ, .eulerYZX:
            selectedProperty = .y
        case .eulerZXY, .eulerZYX:
            break
        default:
            fatalError()
        }
        
    }
    
    var euler: simd_float3 {
        get {
            orientation.euler
        }
        set {
            orientation.euler = newValue
        }
    }
    
    override var selectedProperty: Axis {
        didSet {
            if isActive {
                removeGuideObject()
                setupGuideObject()
            }
        }
    }
    
    override func onActive() {
        setupGuideObject()
    }
    
    override func onInactive() {
        removeGuideObject()
    }
    
    
    func setupGuideObject() {

        let guide = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)
        
        switch selectedProperty {
        case .x:
            SPTScale.make(.init(x: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
            switch orientation.model {
            case .eulerXYZ:
                SPTOrientation.make(.init(eulerX: 0.0, y: orientation.euler.y, z: orientation.euler.z), object: guide)
            case .eulerXZY:
                SPTOrientation.make(.init(eulerX: 0.0, z: orientation.euler.z, y: orientation.euler.y), object: guide)
            case .eulerYXZ:
                SPTOrientation.make(.init(eulerY: 0.0, x: 0.0, z: orientation.euler.z), object: guide)
            case .eulerZXY:
                SPTOrientation.make(.init(eulerZ: 0.0, x: 0.0, y: orientation.euler.y), object: guide)
            default:
                break
            }
            
        case .y:
            SPTScale.make(.init(y: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
            switch orientation.model {
            case .eulerXYZ:
                SPTOrientation.make(.init(eulerX: 0.0, y: 0.0, z: orientation.euler.z), object: guide)
            case .eulerYXZ:
                SPTOrientation.make(.init(eulerY: 0.0, x: orientation.euler.x, z: orientation.euler.z), object: guide)
            case .eulerYZX:
                SPTOrientation.make(.init(eulerY: 0.0, z: orientation.euler.z, x: orientation.euler.x), object: guide)
            case .eulerZYX:
                SPTOrientation.make(.init(eulerZ: 0.0, y: 0.0, x: orientation.euler.x), object: guide)
            default:
                break
            }
            
        case .z:
            SPTScale.make(.init(z: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
            switch orientation.model {
            case .eulerXZY:
                SPTOrientation.make(.init(eulerX: 0.0, z: 0.0, y: orientation.euler.y), object: guide)
            case .eulerYZX:
                SPTOrientation.make(.init(eulerY: 0.0, z: 0.0, x: orientation.euler.x), object: guide)
            case .eulerZXY:
                SPTOrientation.make(.init(eulerZ: 0.0, x: orientation.euler.x, y: orientation.euler.y), object: guide)
            case .eulerZYX:
                SPTOrientation.make(.init(eulerZ: 0.0, y: orientation.euler.y, x: orientation.euler.x), object: guide)
            default:
                break
            }
        }

        guideObject = guide
    }
    
    func removeGuideObject() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}

struct EulerOrientationComponentView: View {
    
    @ObservedObject var component: EulerOrientationComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .x:
                FloatSelector(value: $component.euler.xInDegrees, scale: $editingParams[eulerOrientationOf: component.object].x.scale, isSnappingEnabled: $editingParams[eulerOrientationOf: component.object].x.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .y:
                FloatSelector(value: $component.euler.yInDegrees, scale: $editingParams[eulerOrientationOf: component.object].y.scale, isSnappingEnabled: $editingParams[eulerOrientationOf: component.object].y.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .z:
                FloatSelector(value: $component.euler.zInDegrees, scale: $editingParams[eulerOrientationOf: component.object].z.scale, isSnappingEnabled: $editingParams[eulerOrientationOf: component.object].z.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
}
