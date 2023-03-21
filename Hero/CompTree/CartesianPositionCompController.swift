//
//  CartesianPositionCompController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 19.03.23.
//

import SwiftUI


class CartesianPositionCompController: ObjectCompController {
    
    typealias Property = Axis
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    @SPTObservedComponent private(set) var position: SPTPosition
    private var guideObject: SPTObject?
    
    func infoFor(_ property: Axis) -> ObjectPropertyInfo {
        var propertyId: AnyHashable!
        var value: Binding<Float>!
        switch property {
        case .x:
            propertyId = \SPTPosition.cartesian.x
            value = .init(get: {
                return self.position.cartesian.x
            }, set: {
                self.position.cartesian.x = $0
            })
        case .y:
            propertyId = \SPTPosition.cartesian.y
            value = .init(get: {
                self.position.cartesian.y
            }, set: {
                self.position.cartesian.y = $0
            })
        case .z:
            propertyId = \SPTPosition.cartesian.z
            value = .init(get: {
                self.position.cartesian.z
            }, set: {
                self.position.cartesian.z = $0
            })
        }
        return .init(id: propertyId, typeInfo: .float(value: value, formatter: Formatters.distance), controlTintColor: .primarySelectionColor)
    }
    
    init(object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        _position = SPTObservedComponent(object: object)
        
        super.init()
        
        _position.publisher = self.objectWillChange
    }
    
    override func onActive() {
        setupGuideObject()
    }
    
    override func onInactive() {
        removeGuideObject()
    }
    
    override func onActivePropertyDidChange() {
        removeGuideObject()
        setupGuideObject()
    }
 
    func setupGuideObject() {

        let guide = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: guide)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: guide)

        switch activeProperty {
        case .x:
            SPTScale.make(.init(x: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.xAxisLight.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .y:
            SPTScale.make(.init(y: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.yAxisLight.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
            
        case .z:
            SPTScale.make(.init(z: 500.0), object: guide)
            SPTPolylineLook.make(.init(color: UIColor.zAxisLight.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: guide)
        case .none:
            break
        }

        guideObject = guide
    }
    
    func removeGuideObject() {
        guard let object = guideObject else { return }
        SPTSceneProxy.destroyObject(object)
        guideObject = nil
    }
    
}
