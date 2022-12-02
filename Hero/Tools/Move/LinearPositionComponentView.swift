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
    let distanceFormatter = Formatters.distance

    @SPTObservedComponentProperty<SPTPosition, SPTLinearCoordinates> var linearPosition: SPTLinearCoordinates
    
    var origin: CartesianPositionComponent!
    var directionPoint: CartesianPositionComponent!
    
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<SPTAnySubscription>()
    private var lineGuideObject: SPTObject!
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _linearPosition = .init(object: object, keyPath: \.linear)
        
        super.init(selectedProperty: .offset, parent: parent)
        
        _linearPosition.publisher = self.objectWillChange
        
        origin = makeSubcomponent(title: "Origin", position: linearPosition.origin) { [unowned self] position in
            linearPosition.origin = position.cartesian
            directionPoint.cartesian = linearPosition.origin + linearPosition.direction
            updateLine(originPosition: position, targetPosition: directionPoint.position)
        }
        
        directionPoint = makeSubcomponent(title: "Direction", position: linearPosition.origin + linearPosition.direction) { [unowned self] position in
            linearPosition.direction = position.cartesian - linearPosition.origin
            updateLine(originPosition: origin.position, targetPosition: position)
        }
        
        setupLine()
        
    }
    
    deinit {
        SPTSceneProxy.destroyObject(origin.object)
        SPTSceneProxy.destroyObject(directionPoint.object)
        SPTSceneProxy.destroyObject(lineGuideObject)
    }
    
    private func makeSubcomponent(title: String, position: simd_float3, onPositionChange: @escaping (SPTPosition) -> Void) -> CartesianPositionComponent {
        
        let guidePointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: position), object: guidePointObject)
        
        let subcomponent = CartesianPositionComponent(title: title, editingParamsKeyPath: \.[cartesianPositionOf: guidePointObject], object: guidePointObject, sceneViewModel: sceneViewModel, parent: self)
        
        let cancellable = subcomponent.$isDisclosed.dropFirst().sink { [unowned self] isDisclosed in
            var pointLook = SPTPointLook.get(object: guidePointObject)
            if isDisclosed {
                pointLook.color = UIColor.secondaryLightSelectionColor.rgba
                self.sceneViewModel.focusedObject = guidePointObject
            } else {
                pointLook.color = UIColor.secondarySelectionColor.rgba
                // If this component still 'owns' focused object then revert to the source object otherwise
                // leave as it is. This is relevant when component is closed when entire component tree is removed
                // from the screen
                if self.sceneViewModel.focusedObject == guidePointObject {
                    self.sceneViewModel.focusedObject = self.object
                }
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
        SPTPosition.make(originPosition, object: lineGuideObject)
        SPTScale.make(.init(x: 500.0), object: lineGuideObject)
        SPTOrientation.make(.init(lookAt: .init(target: targetPosition.cartesian, up: lineUpVector(origin: originPosition.cartesian, target: targetPosition.cartesian), axis: .X, positive: true)), object: lineGuideObject)
        SPTPolylineLookDepthBiasMake(lineGuideObject, 5.0, 3.0, 0.0)
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
            switch component.selectedProperty {
            case .offset:
                FloatSelector(value: $component.linearPosition.offset, scale: $editingParams[linearPositionOf: component.object].factor.scale, isSnappingEnabled: $editingParams[linearPositionOf: component.object].factor.isSnapping, formatter: component.distanceFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .none:
                fatalError()
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
}
