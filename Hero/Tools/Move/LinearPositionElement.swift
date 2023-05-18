//
//  LinearPositionElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


struct LinearPositionElement: Element {
    
    static let keyPath = \SPTPosition.linear
    static let originKeyPath = \SPTPosition.linear.origin
    static let directionKeyPath = \SPTPosition.linear.direction
    
    enum Property: Int, ElementProperty {
        case offset
    }
    
    let object: SPTObject
    
    @StateObject private var linear: SPTObservableComponentProperty<SPTPosition, SPTLinearCoordinates>
    @ObjectElementActiveProperty var activeProperty: Property
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originObject: SPTObject!
    @State private var directionObject: SPTObject!
    @State private var lineGuideObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
        _linear = .init(wrappedValue: .init(object: object, keyPath: Self.keyPath))
        _activeProperty = .init(object: object, elementId: Self.keyPath)
    }
    
    var content: some Element {
        CartesianPositionElement(title: "Origin", subtitle: nil, object: object, keyPath: Self.originKeyPath, position: originBinding)
            .onDisclose(onOriginDisclose)
            .onClose(onOriginClose)
            .controlTint(.guide1Light)
        
        CartesianPositionElement(title: "Direction", subtitle: nil, object: object, keyPath: Self.directionKeyPath, position: directionBinding)
            .onDisclose(onDirectionDisclose)
            .onClose(onDirectionClose)
            .controlTint(.guide1Light)
    }
    
    var originBinding: Binding<simd_float3> {
        .init(get: {
            
            linear.origin
            
        }, set: { newValue in
            
            linear.origin = newValue
            
            let originPosition = SPTPosition(cartesian: newValue)
            SPTPosition.update(originPosition, object: originObject)
            
            let targetPosition = SPTPosition(cartesian: newValue + linear.direction)
            SPTPosition.update(targetPosition, object: directionObject)

            updateLine(originPosition: originPosition, targetPosition: targetPosition)
            
        })
    }
    
    func onOriginDisclose() {
        var pointLook = SPTPointLook.get(object: originObject)
        pointLook.color = UIColor.guide1Light.rgba
        SPTPointLook.update(pointLook, object: originObject)
        sceneViewModel.focusedObject = originObject
    }
    
    func onOriginClose() {
        guard SPTIsValid(originObject) else {
            return
        }
        guard var pointLook = SPTPointLook.tryGet(object: originObject) else {
            return
        }
        pointLook.color = UIColor.guide1.rgba
        SPTPointLook.update(pointLook, object: originObject)
    }
    
    var directionBinding: Binding<simd_float3> {
        .init(get: {
            
            linear.origin + linear.direction
            
        }, set: { newValue in
            
            linear.direction = newValue - linear.origin
            
            let targetPosition = SPTPosition(cartesian: newValue)
            SPTPosition.update(targetPosition, object: directionObject)

            updateLine(originPosition: .init(cartesian: linear.origin), targetPosition: targetPosition)
            
        })
    }
    
    func onDirectionDisclose() {
        var pointLook = SPTPointLook.get(object: directionObject)
        pointLook.color = UIColor.guide1Light.rgba
        SPTPointLook.update(pointLook, object: directionObject)
        sceneViewModel.focusedObject = directionObject
    }
    
    func onDirectionClose() {
        guard SPTIsValid(directionObject) else {
            return
        }
        guard var pointLook = SPTPointLook.tryGet(object: directionObject) else {
            return
        }
        pointLook.color = UIColor.guide1.rgba
        SPTPointLook.update(pointLook, object: directionObject)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .offset:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath.appending(path: \.offset), value: $linear.offset, formatter: Formatters.distance)
            }
        }
        .tint(.primarySelectionColor)
    }
    
    var optionsView: some View {
        ObjectCoordinateSystemSelector(object: object)
    }
    
    func onAwake() {
        setupOrigin()
        setupDirection()
        setupLine()
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(lineGuideObject)
        SPTSceneProxy.destroyObject(directionObject)
        SPTSceneProxy.destroyObject(originObject)
    }
    
    func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize, categories: LookCategories.guide.rawValue), object: originObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize, categories: LookCategories.guide.rawValue), object: directionObject)
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: lineGuideObject)
    }
    
    func onClose() {
        SPTPointLook.destroy(object: originObject)
        SPTPointLook.destroy(object: directionObject)
        SPTPolylineLook.destroy(object: lineGuideObject)
    }
    
    func onActive() {
        var lineGuideLook = SPTPolylineLook.get(object: lineGuideObject)
        lineGuideLook.color = UIColor.guide1Light.rgba
        SPTPolylineLook.update(lineGuideLook, object: lineGuideObject)
        sceneViewModel.focusedObject = object
    }
    
    func onInactive() {
        var lineGuideLook = SPTPolylineLook.get(object: lineGuideObject)
        lineGuideLook.color = UIColor.guide1.rgba
        SPTPolylineLook.update(lineGuideLook, object: lineGuideObject)
    }
    
    private func setupOrigin() {
        originObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: linear.origin), object: originObject)
    }
    
    private func setupDirection() {
        directionObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: linear.origin + linear.direction), object: directionObject)
    }
    
    private func setupLine() {
        let originPosition = SPTPosition.get(object: originObject)
        let direction = simd_normalize(SPTPosition.get(object: directionObject).cartesian - originPosition.cartesian)
        
        lineGuideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(originPosition, object: lineGuideObject)
        SPTScale.make(.init(x: 500.0), object: lineGuideObject)
        SPTOrientation.make(.init(normDirection: direction, up: lineUpVector(direction: direction), axis: .X), object: lineGuideObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer2, object: lineGuideObject)
    }
    
    private func updateLine(originPosition: SPTPosition, targetPosition: SPTPosition) {
        SPTPosition.update(originPosition, object: lineGuideObject)
        
        let direction = simd_normalize(targetPosition.cartesian - originPosition.cartesian)
        
        var orientation = SPTOrientation.get(object: lineGuideObject)
        orientation.lookAtDirection.normDirection = direction
        orientation.lookAtDirection.up = lineUpVector(direction: direction)
        SPTOrientation.update(orientation, object: lineGuideObject)
    }
    
    private func lineUpVector(direction: simd_float3) -> simd_float3 {
        // Make sure up and direction vectors are not collinear for correct line orientation
        SPTVector.collinear(direction, .up, tolerance: 0.0001) ? .left : .up
    }
    
    var id: some Hashable {
        Self.keyPath
    }
    
    var title: String {
        "Position"
    }
    
    var subtitle: String? {
        "Linear"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
