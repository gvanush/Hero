//
//  LinearScalePropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.05.23.
//

import SwiftUI


struct LinearScalePropertyAnimatorBindingElement: ScalePropertyAnimatorBindingElement {
    
    typealias Property = AnimatorBindingProperty
    
    let title: String
    let normAxisDirection: simd_float3
    @Binding var propertyValue: Float
    let animatableProperty: SPTAnimatableObjectProperty
    let object: SPTObject
    let defaultValueAt0: Float
    let defaultValueAt1: Float
    let guideColor: UIColor
    let activeGuideColor: UIColor
    
    @ObjectElementActiveProperty var activeProperty: Property
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>>
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var _showsAnimatorSelector: State<Bool>
    @State var lineObject: SPTObject!
    @State var initialPropertyValue: Float!
    
    init(title: String, normAxisDirection: simd_float3, propertyValue: Binding<Float>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, defaultValueAt0: Float, defaultValueAt1: Float, guideColor: UIColor = .guide1Dark, activeGuideColor: UIColor = .guide1Light) {
        self.title = title
        self.normAxisDirection = normAxisDirection
        _propertyValue = propertyValue
        self.animatableProperty = animatableProperty
        self.object = object
        self.defaultValueAt0 = defaultValueAt0
        self.defaultValueAt1 = defaultValueAt1
        self.guideColor = guideColor
        self.activeGuideColor = activeGuideColor
        
        _activeProperty = .init(object: object, elementId: animatableProperty)
        _binding = .init(wrappedValue: .init(property: animatableProperty, object: object))
        
        _showsAnimatorSelector = .init(wrappedValue: false)
    }
    
    func onParentDisclosed() {
        SPTPolylineLook.make(.init(color: activeGuideColor.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineBoldThickness, categories: LookCategories.guide.rawValue), object: lineObject)
    }
    
    func onParentClosed() {
        SPTPolylineLook.destroy(object: lineObject)
    }
    
    func onAwake() {
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: lineObject)
        
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: lineObject)
        // Make sure up and direction vectors are not collinear for correct line orientation
        let up: simd_float3 = SPTVector.collinear(normAxisDirection, .up, tolerance: 0.0001) ? .left : .up
        SPTOrientation.make(.init(normDirection: normAxisDirection, up: up, axis: .X), object: lineObject)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: lineObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(lineObject)
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
