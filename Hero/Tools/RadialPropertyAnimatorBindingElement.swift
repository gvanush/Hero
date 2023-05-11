//
//  RadialPropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.05.23.
//

import SwiftUI

struct RadialPropertyAnimatorBindingElement: ObjectPropertyAnimatorBindingElement {

    typealias Property = AnimatorBindingProperty
    
    let title: String
    let origin: simd_float3
    let normRotationAxis: simd_float3
    let animatableProperty: SPTAnimatableObjectProperty
    let object: SPTObject
    let guideColor: UIColor
    let activeGuideColor: UIColor
    
    @ObjectElementActiveProperty var activeProperty: Property
    var _binding: StateObject<SPTObservableAnimatorBinding<SPTAnimatableObjectProperty>>
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var _showsAnimatorSelector: State<Bool>
    @State var point0Object: SPTObject!
    @State var point1Object: SPTObject!
    @State private var arcObject: SPTObject!
    
    
    init(title: String, origin: simd_float3, normRotationAxis: simd_float3, animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, guideColor: UIColor = .guide1Dark, activeGuideColor: UIColor = .guide1Light) {
        self.title = title
        self.origin = origin
        self.normRotationAxis = normRotationAxis
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
    
    func onParentDisclosed() {
        let objectPosVec = SPTPosition.get(object: object).toCartesian.cartesian - origin
        let arcRadius = simd_length(objectPosVec)
        
        SPTArcLook.make(.init(color: guideColor.rgba, radius: arcRadius, startAngle: binding.valueAt0, endAngle: binding.valueAt1, thickness: .guideLineBoldThickness), object: arcObject)
    }
    
    func onParentClosed() {
        SPTArcLook.destroy(object: arcObject)
    }
    
    func onAwake() {
        let objectPosVec = SPTPosition.get(object: object).toCartesian.cartesian - origin
        let orthoNormal = SPTMatrix3x3.createOrthonormal(normDirection: normRotationAxis, axis: .X)
        let orthoNormalTranspose = simd_transpose(orthoNormal)
        
        let p0 = orthoNormal * SPTOrientationMatrix3x3.createEulerXOrientation(binding.valueAt0) * orthoNormalTranspose * objectPosVec
        
        point0Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin + p0), object: point0Object)

        let p1 = orthoNormal * SPTOrientationMatrix3x3.createEulerXOrientation(binding.valueAt1) * orthoNormalTranspose * objectPosVec
        
        point1Object = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin + p1), object: point1Object)

        arcObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: origin), object: arcObject)
        SPTOrientation.make(.init(orthoNormZ: normRotationAxis, orthoNormX: simd_normalize(objectPosVec)), object: arcObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer3, object: arcObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(point0Object)
        SPTSceneProxy.destroyObject(point1Object)
        SPTSceneProxy.destroyObject(arcObject)
    }
    
    var body: some View {
        animatorBindingElementBody
            .onChange(of: binding.value) { newValue in
                
                guard let binding = newValue else {
                    return
                }
                
                let objectPosVec = SPTPosition.get(object: object).toCartesian.cartesian - origin
                let arcRadius = simd_length(objectPosVec)
                
                let orthoNormal = SPTMatrix3x3.createOrthonormal(normDirection: normRotationAxis, axis: .X)
                let orthoNormalTranspose = simd_transpose(orthoNormal)
                
                let p0 = orthoNormal * SPTOrientationMatrix3x3.createEulerXOrientation(binding.valueAt0) * orthoNormalTranspose * objectPosVec
                SPTPosition.update(.init(cartesian: origin + p0), object: point0Object)
                
                let p1 = orthoNormal * SPTOrientationMatrix3x3.createEulerXOrientation(binding.valueAt1) * orthoNormalTranspose * objectPosVec
                SPTPosition.update(.init(cartesian: origin + p1), object: point1Object)

                SPTArcLook.update(.init(color: guideColor.rgba, radius: arcRadius, startAngle: binding.valueAt0, endAngle: binding.valueAt1, thickness: .guideLineBoldThickness), object: arcObject)
                
            }
    }
    
    var defaultValueAt0: Float { -0.25 * .pi }
    
    var defaultValueAt1: Float { 0.25 * .pi }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
