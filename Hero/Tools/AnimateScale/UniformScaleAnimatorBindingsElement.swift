//
//  UniformScaleAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.05.23.
//

import SwiftUI


struct UniformScaleAnimatorBindingsElement: Element {
    
    let object: SPTObject
    let twinObject: SPTObject
    
    @StateObject private var twinUniform: SPTObservableComponentProperty<SPTScale, Float>
    
    init(object: SPTObject, twinObject: SPTObject) {
        self.object = object
        self.twinObject = twinObject
        _twinUniform = .init(wrappedValue: .init(object: twinObject, keyPath: \.uniform))
    }
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var content: some Element {
        UniformScalePropertyAnimatorBindingElement(title: "Value", propertyValue: $twinUniform.value, animatableProperty: .xyzScaleX, object: object, defaultValueAt0: objectXYZ.x / 1.5, defaultValueAt1: objectXYZ.x * 1.5)
    }
    
    var objectXYZ: simd_float3 {
        SPTScale.get(object: object).xyz
    }
    
    var id: some Hashable {
        \SPTScale.uniform
    }
    
    var title: String {
        "Scale"
    }
    
    var subtitle: String? {
        "Uniform"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
