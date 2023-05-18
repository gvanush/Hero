//
//  RotationPropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.05.23.
//

import SwiftUI


struct RotationPropertyAnimatorBindingElement: PropertyAnimatorBindingElement {
    
    typealias Property = AnimatorBindingProperty
    
    let title: String
    let normAxisDirection: simd_float3
    @Binding var propertyValue: Float
    let animatableProperty: SPTAnimatableObjectProperty
    let object: SPTObject
    let guideColor: UIColor
    let activeGuideColor: UIColor
    
    @ObjectElementActiveProperty var activeProperty: Property
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>>
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var _showsAnimatorSelector: State<Bool>
    @State var lineObject: SPTObject!
    @State var initialPropertyValue: Float!
    
    init(title: String, normAxisDirection: simd_float3, propertyValue: Binding<Float>, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, guideColor: UIColor = .guide1Dark, activeGuideColor: UIColor = .guide1Light) {
        self.title = title
        self.normAxisDirection = normAxisDirection
        _propertyValue = propertyValue
        self.animatableProperty = animatableProperty
        self.object = object
        self.guideColor = guideColor
        self.activeGuideColor = activeGuideColor
        
        _activeProperty = .init(object: object, elementId: animatableProperty)
        _binding = .init(wrappedValue: .init(property: animatableProperty, object: object))
        
        _showsAnimatorSelector = .init(wrappedValue: false)
    }
    
    var actionView: some View {
        switch activeProperty {
        case .valueAt0:
            ObjectFloatPropertySelector(object: object, id: SPTAnimatorBindingPropertyId(animatableProperty: animatableProperty, propertyKeyPath: \.valueAt0), value: _binding.projectedValue.valueAt0InDegrees, formatter: Formatters.angle)
                .tint(Color(uiColor: activeGuideColor))
        case .valueAt1:
            ObjectFloatPropertySelector(object: object, id: SPTAnimatorBindingPropertyId(animatableProperty: animatableProperty, propertyKeyPath: \.valueAt1), value: _binding.projectedValue.valueAt1InDegrees, formatter: Formatters.angle)
                .tint(Color(uiColor: activeGuideColor))
        }
    }
    
    func onActivePropertyChange() {
        updatePropertyValue(binding: binding.value!)
    }
    
    func onDisclose() {
        initialPropertyValue = propertyValue
        
        updatePropertyValue(binding: binding.value!)
    }
    
    func onClose() {
        propertyValue = initialPropertyValue
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
    
    var body: some View {
        animatorBindingElementBody
            .onChange(of: binding.value) { newValue in
                guard let binding = newValue else {
                    return
                }
                updatePropertyValue(binding: binding)
            }
    }
    
    func updatePropertyValue(binding: SPTAnimatorBinding) {
        switch activeProperty {
        case .valueAt0:
            propertyValue = initialPropertyValue + binding.valueAt0
        case .valueAt1:
            propertyValue = initialPropertyValue + binding.valueAt1
        }
    }
    
    var defaultValueAt0: Float { -Float.pi * 0.25 }
    
    var defaultValueAt1: Float { Float.pi * 0.25 }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
