//
//  CylindricalPositionElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.04.23.
//

import SwiftUI


struct CylindricalPositionElement: ComponentElement {
    
    static let keyPath = \SPTPosition.cylindrical
    static let originKeyPath = \SPTPosition.cylindrical.origin
    
    enum Property: Int, ElementProperty {
        case radius
        case height
        case longitude
    }
    
    let object: SPTObject
    
    @StateObject private var cylindrical: SPTObservableComponentProperty<SPTPosition, SPTCylindricalCoordinates>
    @ComponentActiveProperty var activeProperty: Property
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originPointObject: SPTObject!
    @State private var radiusLineObject: SPTObject!
    @State private var heightLineObject: SPTObject!
    @State private var circleObject: SPTObject!
    @State private var circleCenterObject: SPTObject!
    @State private var yAxisObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
        _cylindrical = .init(wrappedValue: .init(object: object, keyPath: Self.keyPath))
        _activeProperty = .init(object: object, componentId: Self.keyPath)
    }
    
    var body: some View {
        defaultBody
            .onChange(of: cylindrical.value) { newValue in
                updateGuideObjects(cylindrical: newValue)
            }
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .radius:
                ComponentFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.radius), value: $cylindrical.radius, formatter: Formatters.distance)
            case .height:
                ComponentFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.height), value: $cylindrical.height, formatter: Formatters.distance)
            case .longitude:
                ComponentFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.longitude), value: $cylindrical.longitudeInDegrees, formatter: Formatters.angle)
            }
        }
        .tint(.primarySelectionColor)
    }
    
    var content: some Element {
        CartesianPositionElement(title: "Origin", subtitle: nil, object: object, keyPath: Self.originKeyPath, position: .init(get: {
            cylindrical.origin
        }, set: {
            SPTPosition.update(.init(cartesian: $0), object: originPointObject)
            cylindrical.origin = $0
        }))
        .onDisclose(onOriginDisclose)
        .onClose(onOriginClose)
        .controlTint(.guide1Light)
    }
    
    func onOriginDisclose() {
        var pointLook = SPTPointLook.get(object: originPointObject)
        pointLook.color = UIColor.guide1Light.rgba
        SPTPointLook.update(pointLook, object: originPointObject)
        sceneViewModel.focusedObject = originPointObject
    }
    
    func onOriginClose() {
        guard SPTIsValid(originPointObject) else {
            return
        }
        guard var pointLook = SPTPointLook.tryGet(object: originPointObject) else {
            return
        }
        pointLook.color = UIColor.guide1.rgba
        SPTPointLook.update(pointLook, object: originPointObject)
    }
    
    func onActivePropertyChange() {
        updateActiveGuideObject()
    }
    
    func onActive() {
        updateActiveGuideObject()
        sceneViewModel.focusedObject = object
    }
    
    func onInactive() {
        updateActiveGuideObject()
    }
    
    func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize, categories: LookCategories.guide.rawValue), object: originPointObject)
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide2.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: heightLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide3.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: circleObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize), object: circleCenterObject)
    }
    
    func onClose() {
        SPTPointLook.destroy(object: originPointObject)
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: heightLineObject)
        SPTPolylineLook.destroy(object: circleObject)
        SPTPointLook.destroy(object: circleCenterObject)
        SPTPolylineLook.destroy(object: yAxisObject)
    }
    
    func onAwake() {
        
        // Setup origin
        originPointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindrical.origin), object: originPointObject)
        
        // Setup radius
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindrical.origin + .init(x: 0.0, y: cylindrical.height, z: 0.0)), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)
        SPTOrientation.make(.init(eulerY: cylindrical.longitude - 0.5 * Float.pi, x: 0.0, z: 0.0), object: radiusLineObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: radiusLineObject)
        
        // Setup height line
        heightLineObject = sceneViewModel.scene.makeObject()
        var heightLinePosition = SPTPosition.get(object: object)
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.make(heightLinePosition, object: heightLineObject)
        SPTScale.make(.init(y: 500.0), object: heightLineObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: heightLineObject)
        
        // Setup circle
        circleObject = sceneViewModel.scene.makeObject()
        let circleCenterPosition = SPTPosition(x: cylindrical.origin.x, y: cylindrical.origin.y + cylindrical.height, z: cylindrical.origin.z)
        SPTPosition.make(circleCenterPosition, object: circleObject)
        SPTScale.make(.init(x: cylindrical.radius, y: cylindrical.radius), object: circleObject)
        SPTOrientation.make(.init(eulerX: 0.5 * Float.pi, y: 0.0, z: 0.0), object: circleObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: circleObject)
        
        // Setup circle center
        circleCenterObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(circleCenterPosition, object: circleCenterObject)
        
        // Setup y axis
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindrical.origin), object: yAxisObject)
        SPTScale.make(.init(y: 500.0), object: yAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: yAxisObject)
        
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(originPointObject)
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(heightLineObject)
        SPTSceneProxy.destroyObject(circleObject)
        SPTSceneProxy.destroyObject(circleCenterObject)
        SPTSceneProxy.destroyObject(yAxisObject)
    }
    
    private func updateActiveGuideObject() {
        var radiusLineLook = SPTPolylineLook.get(object: self.radiusLineObject)
        var heightLineLook = SPTPolylineLook.get(object: self.heightLineObject)
        var circleLook = SPTPolylineLook.get(object: self.circleObject)
        
        switch activeProperty {
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
    
    private func updateGuideObjects(cylindrical: SPTCylindricalCoordinates) {
        SPTPosition.update(.init(cartesian: cylindrical.origin + .init(x: 0.0, y: cylindrical.height, z: 0.0)), object: radiusLineObject)
        SPTOrientation.update(.init(eulerY: cylindrical.longitude - 0.5 * Float.pi, x: 0.0, z: 0.0), object: radiusLineObject)
        
        var heightLineCylindrical = cylindrical
        heightLineCylindrical.height = 0.0
        SPTPosition.update(.init(cylindrical: heightLineCylindrical), object: heightLineObject)
        
        SPTPosition.update(.init(cartesian: cylindrical.origin), object: yAxisObject)
        
        let circleCenterPosition = SPTPosition(x: cylindrical.origin.x, y: cylindrical.origin.y + cylindrical.height, z: cylindrical.origin.z)
        
        SPTPosition.update(circleCenterPosition, object: circleObject)
        SPTScale.update(.init(x: cylindrical.radius, y: cylindrical.radius), object: circleObject)
        
        SPTPosition.update(circleCenterPosition, object: circleCenterObject)
    }
    
    var id: some Hashable {
        Self.keyPath
    }
    
    var title: String {
        "Position"
    }
    
    var subtitle: String? {
        "Cylindrical"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
