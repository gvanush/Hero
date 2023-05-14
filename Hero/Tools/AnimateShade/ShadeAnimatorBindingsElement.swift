//
//  ShadeAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.05.23.
//

import SwiftUI


struct ShadeAnimatorBindingsElement: Element {
    
    let object: SPTObject
    let twinObject: SPTObject
    
    @StateObject private var twinShininess: SPTObservableComponentProperty<SPTMeshLook, Float>
    
    init(object: SPTObject, twinObject: SPTObject) {
        self.object = object
        self.twinObject = twinObject
        _twinShininess = .init(wrappedValue: .init(object: twinObject, keyPath: \.shading.blinnPhong.shininess))
    }
    
    var content: some Element {
        ShininessPropertyAnimatorBindingsElement(title: "Shininess", propertyValue: $twinShininess.value, animatableProperty: .shininess, object: object)
    }
    
    var id: some Hashable {
        \SPTMeshLook.shading
    }
    
    var title: String {
        "Shade"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
