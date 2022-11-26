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
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _position = SPTObservedComponent(object: object)
        
        super.init(selectedProperty: .offset, parent: parent)
        
        _position.publisher = self.objectWillChange
        
        origin = makeSubcomponent(title: "Origin", position: linear.origin) { [unowned self] position in
            linear.origin = position.cartesian
        }
        
        directionPoint = makeSubcomponent(title: "Direction", position: linear.directionPoint) { [unowned self] position in
            linear.directionPoint = position.cartesian
        }
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
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.secondarySelectionColor.rgba, size: 6.0), object: origin.object)
        SPTPointLook.make(.init(color: UIColor.secondarySelectionColor.rgba, size: 6.0), object: directionPoint.object)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: origin.object)
        SPTPointLook.destroy(object: directionPoint.object)
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
            FloatSelector(value: $component.linear.offset, scale: $editingParams[linearPositionOf: component.object].factor.scale, isSnappingEnabled: $editingParams[linearPositionOf: component.object].factor.isSnapping)
                .tint(Color.primarySelectionColor)
                .transition(.identity)
        }
    }
}
