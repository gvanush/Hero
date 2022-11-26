//
//  LinearPositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 23.11.22.
//

import SwiftUI
import Combine

enum LinearPositionComponentProperty: Int, CaseIterable, Displayable {
    case offset
}

class LinearPositionComponent: BasicComponent<LinearPositionComponentProperty> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let positionFormatter = Formatters.positionField

    @SPTObservedComponent private var position: SPTPosition
    
    var origin: CartesianPositionComponent!
    var directionPoint: CartesianPositionComponent!
    
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<SPTAnySubscription>()
    private var lineGuideObject: SPTObject!
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _position = SPTObservedComponent(object: object)
        
        super.init(selectedProperty: .offset, parent: parent)
        
        _position.publisher = self.objectWillChange
        
        origin = makeSubcomponent(title: "Origin", position: linear.origin) { [unowned self] position in
            linear.origin = position.cartesian
            updateLine(originPosition: position, targetPosition: directionPoint.position)
        }
        
        directionPoint = makeSubcomponent(title: "Direction", position: linear.directionPoint) { [unowned self] position in
            linear.directionPoint = position.cartesian
            updateLine(originPosition: origin.position, targetPosition: position)
        }
        
        setupLine()
        
    }
    
    deinit {
        SPTSceneProxy.destroyObject(origin.object)
        SPTSceneProxy.destroyObject(directionPoint.object)
    }
    
    var linear: SPTLinearCoordinates {
        set { position.linear = newValue }
        get { position.linear }
    }
    
    private func makeSubcomponent(title: String, position: simd_float3, onPositionChange: @escaping (SPTPosition) -> Void) -> CartesianPositionComponent {
        
        let guidePointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: position), object: guidePointObject)
        
        let subcomponent = CartesianPositionComponent(title: title, editingParamsKeyPath: \.[cartesianPositionOf: guidePointObject], object: guidePointObject, sceneViewModel: sceneViewModel, parent: self)
        
        let cancellable = subcomponent.$isDisclosed.dropFirst().sink { isDisclosed in
            var pointLook = SPTPointLook.get(object: guidePointObject)
            if isDisclosed {
                pointLook.color = UIColor.secondaryLightSelectionColor.rgba
//                self.sceneViewModel.focusedObject = guidePointObject
            } else {
                pointLook.color = UIColor.secondarySelectionColor.rgba
//                self.sceneViewModel.focusedObject = self.object
            }
            SPTPointLook.update(pointLook, object: guidePointObject)
        }
        cancellables.insert(cancellable)
        
        subscriptions.insert(SPTPosition.onWillChangeSink(object: guidePointObject, callback: onPositionChange))
        
        return subcomponent
    }
    
    private func updateLine(originPosition: SPTPosition, targetPosition: SPTPosition) {
        SPTPosition.update(originPosition, object: lineGuideObject)
        
        var orientation = SPTOrientation.get(object: lineGuideObject)
        orientation.lookAt.target = targetPosition.cartesian
        orientation.lookAt.up = lineUpVector(origin: originPosition.cartesian, target: targetPosition.cartesian)
        SPTOrientation.update(orientation, object: lineGuideObject)
    }
    
    private func setupLine() {
        let originPosition = origin.position
        let targetPosition = directionPoint.position
        
        lineGuideObject = sceneViewModel.scene.makeObject()
        SPTScaleMake(lineGuideObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTPolylineLookDepthBiasMake(lineGuideObject, 5.0, 3.0, 0.0)
        SPTPosition.make(originPosition, object: lineGuideObject)
        SPTOrientation.make(.init(lookAt: .init(target: targetPosition.cartesian, up: lineUpVector(origin: originPosition.cartesian, target: targetPosition.cartesian), axis: .X, positive: true)), object: lineGuideObject)
    }
    
    private func lineUpVector(origin: simd_float3, target: simd_float3) -> simd_float3 {
        // Make sure up and direction vectors are not collinear for correct line orientation
        SPTCollinear(target - origin, .up, 0.0001) ? .left : .up
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.secondarySelectionColor.rgba, size: 7.0, categories: LookCategories.toolGuide.rawValue), object: origin.object)
        SPTPointLook.make(.init(color: UIColor.secondarySelectionColor.rgba, size: 5.0, categories: LookCategories.toolGuide.rawValue), object: directionPoint.object)
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: lineGuideObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: origin.object)
        SPTPointLook.destroy(object: directionPoint.object)
        SPTPolylineLook.destroy(object: lineGuideObject)
    }
    
    override var title: String {
        "Position"
    }
    
    override var subcomponents: [Component]? {
        [origin, directionPoint]
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
}

struct LinearPositionComponentView: View {
    
    @ObservedObject var component: LinearPositionComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            FloatSelector(value: $component.linear.offset, scale: $editingParams[linearPositionOf: component.object].factor.scale, isSnappingEnabled: $editingParams[linearPositionOf: component.object].factor.isSnapping) { editingState in
                userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
            }
            .tint(Color.primarySelectionColor)
            .transition(.identity)
        }
    }
}
