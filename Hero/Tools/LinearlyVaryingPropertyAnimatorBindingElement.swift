//
//  LinearlyVaryingPropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.05.23.
//

import SwiftUI


struct LinearlyVaryingPropertyAnimatorBindingElement: Element {
    
    enum Property: Int, ElementProperty {
        case valueAt0
        case valueAt1
        
        var displayName: String {
            switch self {
            case .valueAt0:
                return "Value:0"
            case .valueAt1:
                return "Value:1"
            }
        }
    }
    
    let title: String
    let normAxisDirection: simd_float3
    let animatableProperty: SPTAnimatableObjectProperty
    let object: SPTObject
    let guideColor: UIColor
    let activeGuideColor: UIColor
    
    @ObjectElementActiveProperty var activeProperty: Property
    @StateObject var binding: SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    @State private var showsAnimatorSelector = false
    @State private var lineObject: SPTObject!
    @State private var point0Object: SPTObject!
    @State private var point1Object: SPTObject!
    
    init(title: String, normAxisDirection: simd_float3, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, guideColor: UIColor = .guide1Dark, activeGuideColor: UIColor = .guide1Light) {
        self.title = title
        self.normAxisDirection = normAxisDirection
        self.animatableProperty = animatableProperty
        self.object = object
        self.guideColor = guideColor
        self.activeGuideColor = activeGuideColor
        
        _activeProperty = .init(object: object, elementId: animatableProperty)
        _binding = .init(wrappedValue: .init(property: animatableProperty, object: object))
    }
    
    var optionsView: some View {
        AnimatorBindingOptionsView(property: animatableProperty, object: object)
    }
    
    var actionView: some View {
        switch activeProperty {
        case .valueAt0:
            ObjectFloatPropertySelector(object: object, id: SPTAnimatorBindingPropertyId(animatableProperty: animatableProperty, propertyKeyPath: \.valueAt0), value: $binding.valueAt0, formatter: Formatters.distance)
                .tint(Color(uiColor: activeGuideColor))
        case .valueAt1:
            ObjectFloatPropertySelector(object: object, id: SPTAnimatorBindingPropertyId(animatableProperty: animatableProperty, propertyKeyPath: \.valueAt1), value: $binding.valueAt1, formatter: Formatters.distance)
                .tint(Color(uiColor: activeGuideColor))
        }
    }
    
    func onDisclose() {

        let point0Color = (activeProperty == .valueAt0 ? activeGuideColor : guideColor).rgba
        SPTPointLook.make(.init(color: point0Color, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: point0Object)
        
        let point1Color = (activeProperty == .valueAt1 ? activeGuideColor : guideColor).rgba
        SPTPointLook.make(.init(color: point1Color, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: point1Object)
        
        switch activeProperty {
        case .valueAt0:
            sceneViewModel.focusedObject = point0Object
        case .valueAt1:
            sceneViewModel.focusedObject = point1Object
        }
    }
    
    func onClose() {
        SPTPointLook.destroy(object: point0Object)
        SPTPointLook.destroy(object: point1Object)
    }
    
    func onAwake() {
        let origin = SPTPosition.get(object: object).toCartesian.cartesian
        let point0Position = SPTPosition(cartesian: origin + binding.valueAt0 * normAxisDirection)
        let point1Position = SPTPosition(cartesian: origin + binding.valueAt1 * normAxisDirection)
        
        point0Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(point0Position, object: point0Object)
        
        point1Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(point1Position, object: point1Object)
        
        lineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: 0.5 * (point0Position.cartesian + point1Position.cartesian)), object: lineObject)
        SPTScale.make(.init(x: 0.5 * (binding.valueAt1 - binding.valueAt0)), object: lineObject)
        // Make sure up and direction vectors are not collinear for correct line orientation
        let up: simd_float3 = SPTVector.collinear(normAxisDirection, .up, tolerance: 0.0001) ? .left : .up
        SPTOrientation.make(.init(normDirection: normAxisDirection, up: up, axis: .X), object: lineObject)
        SPTLineLookDepthBias.make(.guideLineLayer3, object: lineObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(lineObject)
        SPTSceneProxy.destroyObject(point0Object)
        SPTSceneProxy.destroyObject(point1Object)
    }
    
    func onParentDisclosed() {
        SPTPolylineLook.make(.init(color: guideColor.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineBoldThickness, categories: LookCategories.guide.rawValue), object: lineObject)
    }
    
    func onParentClosed() {
        SPTPolylineLook.destroy(object: lineObject)
    }
    
    func onPrepare() {
        showsAnimatorSelector = true
    }
    
    var isReady: Bool {
        animatableProperty.isAnimatorBound(object: object)
    }
    
    var body: some View {
        defaultBody
            .sheet(isPresented: $showsAnimatorSelector) {
                AnimatorSelector { animatorId in
                    if let animatorId {
                        animatableProperty.bind(.init(animatorId: animatorId, valueAt0: -5.0, valueAt1: 5.0), object: object)
                    }
                    showsAnimatorSelector = false
                    activeIndexPath = indexPath
                }
            }
    }
    
    var rearView: some View {
        defaultRearView
            .onChange(of: binding.value) { newValue in
                
                guard let binding = newValue else {
                    return
                }
                
                let origin = SPTPosition.get(object: object).toCartesian.cartesian
                
                let point0Position = SPTPosition(cartesian: origin + binding.valueAt0 * normAxisDirection)
                let point1Position = SPTPosition(cartesian: origin + binding.valueAt1 * normAxisDirection)
                
                SPTPosition.update(point0Position, object: point0Object)
                SPTPosition.update(point1Position, object: point1Object)
                
                SPTPosition.update(.init(cartesian: 0.5 * (point0Position.cartesian + point1Position.cartesian)), object: lineObject)
                SPTScale.update(.init(x: 0.5 * (binding.valueAt1 - binding.valueAt0)), object: lineObject)
            }
            .onChange(of: activeProperty) { newValue in
                var point0Look = SPTPointLook.get(object: point0Object)
                var point1Look = SPTPointLook.get(object: point1Object)
                
                switch newValue {
                case .valueAt0:
                    point0Look.color = activeGuideColor.rgba
                    point1Look.color = guideColor.rgba
                    sceneViewModel.focusedObject = point0Object
                case .valueAt1:
                    point0Look.color = guideColor.rgba
                    point1Look.color = activeGuideColor.rgba
                    sceneViewModel.focusedObject = point1Object
                }
                
                SPTPointLook.update(point0Look, object: point0Object)
                SPTPointLook.update(point1Look, object: point1Object)
            }
    }
    
    var subtitle: String? {
        if let animatorId = binding.value?.animatorId {
            return SPTAnimator.get(id: animatorId).name
        }
        return nil
    }
    
    var id: some Hashable {
        animatableProperty
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
}
