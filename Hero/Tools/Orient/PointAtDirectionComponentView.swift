//
//  PointAtDirectionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.01.23.
//

import SwiftUI
import Combine


enum PointAtDirectionComponentProperty: Int, CaseIterable, Displayable {
    case angle
    case axis
}

class PointAtDirectionComponent: BasicComponent<PointAtDirectionComponentProperty> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let angleFormatter = Formatters.angle
    
    @SPTObservedComponent var orientation: SPTOrientation
    
    private var directionPoint: CartesianPositionComponent!
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<SPTAnySubscription>()
    private var lineGuideObject: SPTObject!
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _orientation = .init(object: object)
        
        super.init(selectedProperty: .angle, parent: parent)
        
        _orientation.publisher = objectWillChange
        
        setupDirectionPointSubcomponent()
        setupLine()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(directionPoint.object)
        SPTSceneProxy.destroyObject(lineGuideObject)
    }
    
    
    
    private func setupDirectionPointSubcomponent() {
        
        let guidePointObject = sceneViewModel.scene.makeObject()
        let guideCartesian = SPTPosition.get(object: object).toCartesian.cartesian + SPTOrientation.get(object: object).pointAtDirection.direction
        SPTPosition.make(.init(cartesian: guideCartesian), object: guidePointObject)
        
        directionPoint = CartesianPositionComponent(title: "Direction", editingParamsKeyPath: \.[cartesianPositionOf: guidePointObject], object: guidePointObject, sceneViewModel: sceneViewModel, parent: self)
        directionPoint.objectSelectionColor = UIColor.guide1Light
        
        let cancellable = directionPoint.$isDisclosed.dropFirst().sink { [unowned self] isDisclosed in
            var pointLook = SPTPointLook.get(object: guidePointObject)
            if isDisclosed {
                pointLook.color = UIColor.guide1Light.rgba
                self.sceneViewModel.focusedObject = guidePointObject
            } else {
                pointLook.color = UIColor.guide1.rgba
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
        
        subscriptions.insert(SPTPosition.onWillChangeSink(object: guidePointObject, callback: { [unowned self] position in
            
            orientation.pointAtDirection.direction = position.cartesian - SPTPosition.get(object: object).toCartesian.cartesian
            
            var lineGuideOrientation = SPTOrientation.get(object: lineGuideObject)
            lineGuideOrientation.lookAtDirection.normDirection = simd_normalize(orientation.pointAtDirection.direction)
            SPTOrientation.update(lineGuideOrientation, object: lineGuideObject)
        }))
        
    }
    
    private func setupLine() {
        lineGuideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: lineGuideObject)
        SPTScale.make(.init(x: 500.0), object: lineGuideObject)
        
        let direction = orientation.pointAtDirection.direction
        SPTOrientation.make(.init(normDirection: direction, up: lineUpVector(direction: direction), axis: .X), object: lineGuideObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer2, object: lineGuideObject)
    }
    
    private func lineUpVector(direction: simd_float3) -> simd_float3 {
        // Make sure up and direction vectors are not collinear for correct line orientation
        SPTVector.collinear(direction, .up, tolerance: 0.0001) ? .left : .up
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize, categories: LookCategories.guide.rawValue), object: directionPoint.object)
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: lineGuideObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: directionPoint.object)
        SPTPolylineLook.destroy(object: lineGuideObject)
    }
    
    override var title: String {
        "Position"
    }
    
    override var subcomponents: [Component]? {
        [directionPoint]
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
}


struct PointAtDirectionComponentView: View {
    
    @ObservedObject var component: PointAtDirectionComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .angle:
                FloatSelector(value: $component.orientation.pointAtDirection.angle, scale: $editingParams[linearPositionOf: component.object].factor.scale, isSnappingEnabled: $editingParams[linearPositionOf: component.object].factor.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .axis:
                DiscreteValueSelector(selected: $component.orientation.pointAtDirection.axis)
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
}
