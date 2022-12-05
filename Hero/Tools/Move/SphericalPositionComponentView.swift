//
//  SphericalPositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.11.22.
//

import SwiftUI
import Combine


enum SphericalPositionComponentProperty: Int, CaseIterable, Displayable {
    case latitude
    case longitude
    case radius
}

class SphericalPositionComponent: BasicComponent<SphericalPositionComponentProperty> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let distanceFormatter = Formatters.distance
    let angleFormatter = Formatters.angle

    @SPTObservedComponentProperty<SPTPosition, SPTSphericalCoordinates> var sphericalPosition: SPTSphericalCoordinates
    
    var origin: CartesianPositionComponent!
    
    private var radiusLineObject: SPTObject!
    private var latitudeCircleObject: SPTObject!
    private var longitudeCircleObject: SPTObject!
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<SPTAnySubscription>()
    
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _sphericalPosition = .init(object: object, keyPath: \.spherical)
        
        super.init(selectedProperty: .latitude, parent: parent)
        
        _sphericalPosition.publisher = self.objectWillChange
        
        setupOrigin()
        setupLatitudeCircle()
        setupLongitudeCircle()
        setupRadiusLine()
        
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
        SPTSceneProxy.destroyObject(latitudeCircleObject)
        SPTSceneProxy.destroyObject(longitudeCircleObject)
        SPTSceneProxy.destroyObject(radiusLineObject)
    }
    
    private func setupOrigin() {
        
        let guidePointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: guidePointObject)
        
        origin = CartesianPositionComponent(title: "Origin", editingParamsKeyPath: \.[cartesianPositionOf: guidePointObject], object: guidePointObject, sceneViewModel: sceneViewModel, parent: self)
        
        let cancellable = origin.$isDisclosed.dropFirst().sink { [unowned self] isDisclosed in
            var pointLook = SPTPointLook.get(object: guidePointObject)
            if isDisclosed {
                pointLook.color = UIColor.selectedGuideColor.rgba
                self.sceneViewModel.focusedObject = guidePointObject
            } else {
                pointLook.color = UIColor.guideColor.rgba
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
            self.sphericalPosition.origin = position.cartesian
        }))
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guideColor.rgba, size: .guidePointLargeSize, categories: LookCategories.guide.rawValue), object: origin.object)
        SPTPolylineLook.make(.init(color: UIColor.guideColor.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: latitudeCircleObject)
        SPTPolylineLook.make(.init(color: UIColor.guideColor.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: longitudeCircleObject)
        SPTPolylineLook.make(.init(color: UIColor.guideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        
        updateSelectedGuideObject(selectedProperty: selectedProperty!)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: origin.object)
        SPTPolylineLook.destroy(object: latitudeCircleObject)
        SPTPolylineLook.destroy(object: longitudeCircleObject)
        SPTPolylineLook.destroy(object: radiusLineObject)
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
        let cartesian = position.spherical.toCartesian
        let lineDirection = simd_normalize(cartesian - position.spherical.origin)
        
        SPTPosition.update(.init(cartesian: position.spherical.origin), object: radiusLineObject)
        SPTOrientation.update(.init(normDirection: lineDirection, up: radiusUpVector(direction: lineDirection), axis: .X), object: radiusLineObject)

        SPTPosition.update(origin.position, object: latitudeCircleObject)
        SPTScale.update(.init(x: sphericalPosition.radius, y: sphericalPosition.radius), object: latitudeCircleObject)
        SPTOrientation.update(.init(y: 0.5 * Float.pi + position.spherical.longitude), object: latitudeCircleObject)
        
        SPTPosition.update(.init(x: origin.cartesian.x, y: cartesian.y, z: origin.cartesian.z), object: longitudeCircleObject)
        let vec = cartesian - position.spherical.origin
        let scale = simd_length(.init(x: vec.x, y: vec.z))
        SPTScale.update(.init(x: scale, y: scale), object: longitudeCircleObject)
        
    }

    private func setupRadiusLine() {
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin.position, object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)
        let cartesian = sphericalPosition.toCartesian
        let direction = simd_normalize(cartesian - origin.cartesian)
        SPTOrientation.make(.init(normDirection: direction, up: radiusUpVector(direction: direction), axis: .X), object: radiusLineObject)
        
        SPTPolylineLookDepthBias.make(.guideLineLayer2, object: radiusLineObject)
    }

    private func setupLatitudeCircle() {
        latitudeCircleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin.position, object: latitudeCircleObject)
        SPTScale.make(.init(x: sphericalPosition.radius, y: sphericalPosition.radius), object: latitudeCircleObject)
        SPTOrientation.make(.init(y: 0.5 * Float.pi + sphericalPosition.longitude), object: latitudeCircleObject)
        SPTPolylineLookDepthBias.make(.guideLineLayer2, object: latitudeCircleObject)
    }

    private func setupLongitudeCircle() {
        longitudeCircleObject = sceneViewModel.scene.makeObject()
        
        let cartesian = sphericalPosition.toCartesian
        SPTPosition.make(.init(x: origin.cartesian.x, y: cartesian.y, z: origin.cartesian.z), object: longitudeCircleObject)
        
        let vec = cartesian - origin.cartesian
        let scale = simd_length(.init(x: vec.x, y: vec.z))
        
        SPTScale.make(.init(x: scale, y: scale), object: longitudeCircleObject)
        SPTOrientation.make(.init(x: 0.5 * Float.pi), object: longitudeCircleObject)
        SPTPolylineLookDepthBias.make(.guideLineLayer2, object: longitudeCircleObject)
    }
    
    private func updateSelectedGuideObject(selectedProperty: SphericalPositionComponentProperty) {
        var radiusLineLook = SPTPolylineLook.get(object: self.radiusLineObject)
        var latitudeCircleLook = SPTPolylineLook.get(object: self.latitudeCircleObject)
        var longitudeCircleLook = SPTPolylineLook.get(object: self.longitudeCircleObject)

        switch selectedProperty {
        case .latitude:
            radiusLineLook.color = UIColor.guideColor.rgba
            latitudeCircleLook.color = isActive ? UIColor.selectedGuideColor.rgba : UIColor.guideColor.rgba
            longitudeCircleLook.color = UIColor.guideColor.rgba
        case .longitude:
            radiusLineLook.color = UIColor.guideColor.rgba
            latitudeCircleLook.color = UIColor.guideColor.rgba
            longitudeCircleLook.color = isActive ? UIColor.selectedGuideColor.rgba : UIColor.guideColor.rgba
        case .radius:
            radiusLineLook.color = isActive ? UIColor.selectedGuideColor.rgba : UIColor.guideColor.rgba
            latitudeCircleLook.color = UIColor.guideColor.rgba
            longitudeCircleLook.color = UIColor.guideColor.rgba
        }

        SPTPolylineLook.update(radiusLineLook, object: self.radiusLineObject)
        SPTPolylineLook.update(latitudeCircleLook, object: self.latitudeCircleObject)
        SPTPolylineLook.update(longitudeCircleLook, object: self.longitudeCircleObject)
    }
    
    private func radiusUpVector(direction: simd_float3) -> simd_float3 {
        // Make sure up and direction vectors are not collinear for correct line orientation
        SPTCollinear(direction, .up, 0.0001) ? .left : .up
    }
}

struct SphericalPositionComponentView: View {
    
    @ObservedObject var component: SphericalPositionComponent
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .latitude:
                FloatSelector(value: $component.sphericalPosition.latitudeInDegrees, scale: $editingParams[sphericalPositionOf: component.object].latitude.scale, isSnappingEnabled: $editingParams[sphericalPositionOf: component.object].latitude.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .longitude:
                FloatSelector(value: $component.sphericalPosition.longitudeInDegrees, scale: $editingParams[sphericalPositionOf: component.object].longitude.scale, isSnappingEnabled: $editingParams[sphericalPositionOf: component.object].longitude.isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .radius:
                FloatSelector(value: $component.sphericalPosition.radius, scale: $editingParams[sphericalPositionOf: component.object].radius.scale, isSnappingEnabled: $editingParams[sphericalPositionOf: component.object].radius.isSnapping, formatter: component.distanceFormatter) { editingState in
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
