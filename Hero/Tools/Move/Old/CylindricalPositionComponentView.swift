//
//  CylindricalPositionComponentView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.11.22.
//

import SwiftUI
import Combine


enum CylindricalPositionComponentProperty: Int, CaseIterable, Displayable {
    case radius
    case height
    case longitude
}

class CylindricalPositionComponent: BasicComponent<CylindricalPositionComponentProperty> {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    let distanceFormatter = Formatters.distance
    let angleFormatter = Formatters.angle

    @SPTListenedComponentProperty<SPTPosition, SPTCylindricalCoordinates> var cylindricalPosition: SPTCylindricalCoordinates
    
    var origin: CartesianPositionComponent!
    
    private var radiusLineObject: SPTObject!
    private var heightLineObject: SPTObject!
    private var circleObject: SPTObject!
    private var circleCenterObject: SPTObject!
    private var yAxisObject: SPTObject!
    private var cancellables = Set<AnyCancellable>()
    private var subscriptions = Set<SPTAnySubscription>()
    
    
    init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _cylindricalPosition = .init(object: object, keyPath: \.cylindrical)
        
        super.init(selectedProperty: .radius, parent: parent)
        
        _cylindricalPosition.publisher = self.objectWillChange
        
        setupOrigin()
        setupRadiusLine()
        setupHeightLine()
        setupCircle()
        setupYAxis()
        
        subscriptions.insert(SPTPosition.onWillChangeSink(object: object) { [unowned self] position in
            updateGuideObjects(position: position)
        })
        
        cancellables.insert($selectedProperty.dropFirst().sink { [unowned self] newValue in
            guard isDisclosed else {
                return
            }
            updateSelectedGuideObject(selectedProperty: newValue)
        })
    }
    
    deinit {
        SPTSceneProxy.destroyObject(origin.object)
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(heightLineObject)
        SPTSceneProxy.destroyObject(circleObject)
        SPTSceneProxy.destroyObject(circleCenterObject)
        SPTSceneProxy.destroyObject(yAxisObject)
    }
    
    private func setupOrigin() {
        
        let guidePointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindricalPosition.origin), object: guidePointObject)
        
        origin = CartesianPositionComponent(title: "Origin", object: guidePointObject, sceneViewModel: sceneViewModel, parent: self)
        origin.objectSelectionColor = UIColor.guide1Light
        
        let cancellable = origin.$isDisclosed.dropFirst().sink { [unowned self] isDisclosed in
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
            self.cylindricalPosition.origin = position.cartesian
        }))
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize, categories: LookCategories.guide.rawValue), object: origin.object)
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide2.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: heightLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide3.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: circleObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize), object: circleCenterObject)
        
        updateSelectedGuideObject(selectedProperty: selectedProperty)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: origin.object)
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: heightLineObject)
        SPTPolylineLook.destroy(object: circleObject)
        SPTPointLook.destroy(object: circleCenterObject)
        SPTPolylineLook.destroy(object: yAxisObject)
    }
    
    override func onActive() {
        updateSelectedGuideObject(selectedProperty: selectedProperty)
    }
    
    override func onInactive() {
        updateSelectedGuideObject(selectedProperty: selectedProperty)
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
        SPTOrientation.update(.init(eulerY: position.cylindrical.longitude - 0.5 * Float.pi, x: 0.0, z: 0.0), object: radiusLineObject)
        
        var heightLinePosition = position
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.update(heightLinePosition, object: heightLineObject)
        
        SPTPosition.update(origin.position, object: yAxisObject)
        
        let circleCenterPosition = SPTPosition(x: origin.cartesian.x, y: origin.cartesian.y + cylindricalPosition.height, z: origin.cartesian.z)
        
        SPTPosition.update(circleCenterPosition, object: circleObject)
        SPTScale.update(.init(x: cylindricalPosition.radius, y: cylindricalPosition.radius), object: circleObject)
        
        SPTPosition.update(circleCenterPosition, object: circleCenterObject)
    }
    
    private func setupRadiusLine() {
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindricalPosition.origin + .init(x: 0.0, y: cylindricalPosition.height, z: 0.0)), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)
        SPTOrientation.make(.init(eulerY: cylindricalPosition.longitude - 0.5 * Float.pi, x: 0.0, z: 0.0), object: radiusLineObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: radiusLineObject)
    }
    
    private func setupHeightLine() {
        heightLineObject = sceneViewModel.scene.makeObject()
        var heightLinePosition = SPTPosition.get(object: object)
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.make(heightLinePosition, object: heightLineObject)
        SPTScale.make(.init(y: 500.0), object: heightLineObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: heightLineObject)
    }
    
    private func setupCircle() {
        circleObject = sceneViewModel.scene.makeObject()
        
        let circleCenterPosition = SPTPosition(x: origin.cartesian.x, y: origin.cartesian.y + cylindricalPosition.height, z: origin.cartesian.z)
        SPTPosition.make(circleCenterPosition, object: circleObject)
        SPTScale.make(.init(x: cylindricalPosition.radius, y: cylindricalPosition.radius), object: circleObject)
        SPTOrientation.make(.init(eulerX: 0.5 * Float.pi, y: 0.0, z: 0.0), object: circleObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: circleObject)
        
        circleCenterObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(circleCenterPosition, object: circleCenterObject)
    }
    
    private func setupYAxis() {
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin.position, object: yAxisObject)
        SPTScale.make(.init(y: 500.0), object: yAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: yAxisObject)
    }
    
    private func updateSelectedGuideObject(selectedProperty: CylindricalPositionComponentProperty) {
        var radiusLineLook = SPTPolylineLook.get(object: self.radiusLineObject)
        var heightLineLook = SPTPolylineLook.get(object: self.heightLineObject)
        var circleLook = SPTPolylineLook.get(object: self.circleObject)
        
        switch selectedProperty {
        case .longitude:
            radiusLineLook.color = UIColor.guide1.rgba
            heightLineLook.color = UIColor.guide2.rgba
            circleLook.color = isActive ? UIColor.guide3Light.rgba : UIColor.guide3.rgba
        case .radius:
            radiusLineLook.color = isActive ? UIColor.guide1Light.rgba : UIColor.guide1.rgba
            heightLineLook.color = UIColor.guide2.rgba
            circleLook.color = UIColor.guide3.rgba
        case .height:
            radiusLineLook.color = UIColor.guide1.rgba
            heightLineLook.color = isActive ? UIColor.guide2Light.rgba : UIColor.guide2.rgba
            circleLook.color = UIColor.guide3.rgba
        }
        
        SPTPolylineLook.update(radiusLineLook, object: self.radiusLineObject)
        SPTPolylineLook.update(heightLineLook, object: self.heightLineObject)
        SPTPolylineLook.update(circleLook, object: self.circleObject)
    }
    
}

struct CylindricalPositionComponentView: View {
    
    @ObservedObject var component: CylindricalPositionComponent
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        Group {
            switch component.selectedProperty {
            case .longitude:
                FloatSelector(value: $component.cylindricalPosition.longitudeInDegrees, scale: editingParam(\.longitude).scale, isSnappingEnabled: editingParam(\.longitude).isSnapping, formatter: component.angleFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .radius:
                FloatSelector(value: $component.cylindricalPosition.radius, scale: editingParam(\.radius).scale, isSnappingEnabled: editingParam(\.radius).isSnapping, formatter: component.distanceFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            case .height:
                FloatSelector(value: $component.cylindricalPosition.height, scale: editingParam(\.height).scale, isSnappingEnabled: editingParam(\.height).isSnapping, formatter: component.distanceFormatter) { editingState in
                    userInteractionState.isEditing = (editingState != .idle && editingState != .snapping)
                }
            }
        }
        .tint(Color.primarySelectionColor)
        .transition(.identity)
    }
    
    func editingParam(_ keyPath: KeyPath<SPTCylindricalCoordinates, Float>) -> Binding<ObjectPropertyFloatEditingParams> {
        $editingParams[floatPropertyId: (\SPTPosition.cylindrical).appending(path: keyPath), component.object]
    }
    
}
