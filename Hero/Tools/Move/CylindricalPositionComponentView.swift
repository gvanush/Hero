//
//  CylindricalPositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.11.22.
//

import SwiftUI
import Combine


enum CylindricalPositionComponentProperty: Int, CaseIterable, Displayable {
    case longitude
    case radius
    case height
}

class CylindricalPositionComponent: BasicComponent<CylindricalPositionComponentProperty> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let lengthFormatter = Formatters.length
    let angleFormatter = Formatters.angle

    @SPTObservedComponentProperty<SPTPosition, SPTCylindricalCoordinates> var cylindricalPosition: SPTCylindricalCoordinates
    
    var origin: CartesianPositionComponent!
    
    private var radiusLineObject: SPTObject!
    private var heightLineObject: SPTObject!
    private var circleOutlineObject: SPTObject!
    private var yAxisObject: SPTObject!
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<SPTAnySubscription>()
    
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _cylindricalPosition = .init(object: object, keyPath: \.cylindrical)
        
        super.init(selectedProperty: .longitude, parent: parent)
        
        _cylindricalPosition.publisher = self.objectWillChange
        
        setupOrigin()
        setupRadiusLine()
        setupHeightLine()
        setupCircleOutline()
        setupYAxis()
        
        subscriptions.insert(SPTPosition.onWillChangeSink(object: object) { [unowned self] position in
            updateGuideObjects(position: position)
        })
        
        cancellables.insert($selectedProperty.dropFirst().sink { [unowned self] newValue in
            guard isDisclosed else {
                return
            }
            updateSelectedGuideObject(selectedProperty: newValue!)
        })
    }
    
    deinit {
        SPTSceneProxy.destroyObject(origin.object)
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(heightLineObject)
        SPTSceneProxy.destroyObject(circleOutlineObject)
        SPTSceneProxy.destroyObject(yAxisObject)
    }
    
    private func setupOrigin() {
        
        let guidePointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindricalPosition.origin), object: guidePointObject)
        
        origin = CartesianPositionComponent(title: "Origin", editingParamsKeyPath: \.[cartesianPositionOf: guidePointObject], object: guidePointObject, sceneViewModel: sceneViewModel, parent: self)
        
        let cancellable = origin.$isDisclosed.dropFirst().sink { [unowned self] isDisclosed in
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
        
        subscriptions.insert(SPTPosition.onWillChangeSink(object: guidePointObject, callback: { [unowned self] position in
            self.cylindricalPosition.origin = position.cartesian
        }))
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.secondarySelectionColor.rgba, size: 7.0, categories: LookCategories.toolGuide.rawValue), object: origin.object)
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.halfLineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.halfLineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: heightLineObject)
        SPTPolylineLook.make(.init(color: UIColor.secondarySelectionColor.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: circleOutlineObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.lineMeshId, thickness: 3.0, categories: LookCategories.toolGuide.rawValue), object: yAxisObject)
        
        updateSelectedGuideObject(selectedProperty: selectedProperty!)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: origin.object)
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: heightLineObject)
        SPTPolylineLook.destroy(object: circleOutlineObject)
        SPTPolylineLook.destroy(object: yAxisObject)
    }
    
    override func onActive() {
        updateSelectedGuideObject(selectedProperty: selectedProperty!)
    }
    
    override func onInactive() {
        updateSelectedGuideObject(selectedProperty: selectedProperty!)
    }
    
    override var title: String {
        "Position"
    }
    
    override var subcomponents: [Component]? {
        [origin]
    }
    
    override func accept<RC>(_ provider: ComponentViewProvider<RC>) -> AnyView? {
        provider.viewFor(self)
    }
    
    private func updateGuideObjects(position: SPTPosition) {
        SPTPosition.update(.init(cartesian: position.cylindrical.origin + .init(x: 0.0, y: position.cylindrical.height, z: 0.0)), object: radiusLineObject)
        SPTScale.update(.init(x: position.cylindrical.radius), object: radiusLineObject)
        SPTOrientation.update(.init(y: position.cylindrical.longitude - 0.5 * Float.pi), object: radiusLineObject)
        
        var heightLinePosition = position
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.update(heightLinePosition, object: heightLineObject)
        SPTScale.update(.init(x: cylindricalPosition.height), object: heightLineObject)
        
        SPTPosition.update(origin.position, object: yAxisObject)
        
        SPTPosition.update(origin.position, object: circleOutlineObject)
        SPTScale.update(.init(x: cylindricalPosition.radius, y: cylindricalPosition.radius), object: circleOutlineObject)
    }
    
    private func setupRadiusLine() {
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindricalPosition.origin + .init(x: 0.0, y: cylindricalPosition.height, z: 0.0)), object: radiusLineObject)
        SPTScale.make(.init(x: cylindricalPosition.radius), object: radiusLineObject)
        SPTOrientation.make(.init(y: cylindricalPosition.longitude - 0.5 * Float.pi), object: radiusLineObject)
        SPTPolylineLookDepthBiasMake(radiusLineObject, 5.0, 3.0, 0.0)
    }
    
    private func setupHeightLine() {
        heightLineObject = sceneViewModel.scene.makeObject()
        var heightLinePosition = SPTPosition.get(object: object)
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.make(heightLinePosition, object: heightLineObject)
        SPTScale.make(.init(x: cylindricalPosition.height), object: heightLineObject)
        SPTOrientation.make(.init(z: 0.5 * Float.pi), object: heightLineObject)
        SPTPolylineLookDepthBiasMake(heightLineObject, 5.0, 3.0, 0.0)
    }
    
    private func setupCircleOutline() {
        circleOutlineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin.position, object: circleOutlineObject)
        SPTScale.make(.init(x: cylindricalPosition.radius, y: cylindricalPosition.radius), object: circleOutlineObject)
        SPTOrientation.make(.init(x: 0.5 * Float.pi), object: circleOutlineObject)
        SPTPolylineLookDepthBiasMake(circleOutlineObject, 5.0, 3.0, 0.0)
    }
    
    private func setupYAxis() {
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin.position, object: yAxisObject)
        SPTScale.make(.init(x: 500.0), object: yAxisObject)
        SPTOrientation.make(.init(z: Float.pi * 0.5), object: yAxisObject)
        SPTPolylineLookDepthBiasMake(yAxisObject, 5.0, 3.0, 0.0)
    }
    
    private func updateSelectedGuideObject(selectedProperty: CylindricalPositionComponentProperty) {
        var radiusLineLook = SPTPolylineLook.get(object: self.radiusLineObject)
        var heightLineLook = SPTPolylineLook.get(object: self.heightLineObject)
        var circleOutlineLook = SPTPolylineLook.get(object: self.circleOutlineObject)
        
        switch selectedProperty {
        case .longitude:
            radiusLineLook.color = UIColor.secondarySelectionColor.rgba
            heightLineLook.color = UIColor.secondarySelectionColor.rgba
            circleOutlineLook.color = isActive ? UIColor.secondaryLightSelectionColor.rgba : UIColor.secondarySelectionColor.rgba
        case .radius:
            radiusLineLook.color = isActive ? UIColor.secondaryLightSelectionColor.rgba : UIColor.secondarySelectionColor.rgba
            heightLineLook.color = UIColor.secondarySelectionColor.rgba
            circleOutlineLook.color = UIColor.secondarySelectionColor.rgba
        case .height:
            radiusLineLook.color = UIColor.secondarySelectionColor.rgba
            heightLineLook.color = isActive ? UIColor.secondaryLightSelectionColor.rgba : UIColor.secondarySelectionColor.rgba
            circleOutlineLook.color = UIColor.secondarySelectionColor.rgba
        }
        
        SPTPolylineLook.update(radiusLineLook, object: self.radiusLineObject)
        SPTPolylineLook.update(heightLineLook, object: self.heightLineObject)
        SPTPolylineLook.update(circleOutlineLook, object: self.circleOutlineObject)
    }
    
}

struct CylindricalPositionComponentView: View {
    
    @ObservedObject var component: CylindricalPositionComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .longitude:
                FloatSelector(value: $component.cylindricalPosition.longitudeInDegrees, scale: $editingParams[cylindricalPositionOf: component.object].longitude.scale, isSnappingEnabled: $editingParams[cylindricalPositionOf: component.object].longitude.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .radius:
                FloatSelector(value: $component.cylindricalPosition.radius, scale: $editingParams[cylindricalPositionOf: component.object].radius.scale, isSnappingEnabled: $editingParams[cylindricalPositionOf: component.object].radius.isSnapping, formatter: component.lengthFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .height:
                FloatSelector(value: $component.cylindricalPosition.height, scale: $editingParams[cylindricalPositionOf: component.object].height.scale, isSnappingEnabled: $editingParams[cylindricalPositionOf: component.object].height.isSnapping, formatter: component.lengthFormatter) { editingState in
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
