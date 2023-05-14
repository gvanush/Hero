//
//  ShadeAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.05.23.
//

import SwiftUI


struct ShadeAnimatorBindingsElement: Element {
    
    static let colorKeyPath = \SPTMeshLook.shading.blinnPhong.color
    
    let object: SPTObject
    let twinObject: SPTObject
    
    @StateObject private var twinShininess: SPTObservableComponentProperty<SPTMeshLook, Float>
    @StateObject private var twinColor: SPTObservableComponentProperty<SPTMeshLook, SPTColor>
    
    init(object: SPTObject, twinObject: SPTObject) {
        self.object = object
        self.twinObject = twinObject
        _twinShininess = .init(wrappedValue: .init(object: twinObject, keyPath: \.shading.blinnPhong.shininess))
        _twinColor = .init(wrappedValue: .init(object: twinObject, keyPath: Self.colorKeyPath))
    }
    
    var content: some Element {
        ShininessPropertyAnimatorBindingElement(title: "Shininess", propertyValue: $twinShininess.value, animatableProperty: .shininess, object: object)
        switch twinColor.model {
        case .HSB:
            CompositeElement(id: Self.colorKeyPath.appending(path: \.hsba), title: "Color", subtitle: "HSB") {
                HSBColorChannelPropertyAnimatorBindingElement(title: "Hue", channel: .hue, propertyValue: $twinColor.hsba, animatableProperty: .hue, object: object)
                HSBColorChannelPropertyAnimatorBindingElement(title: "Saturation", channel: .saturation, propertyValue: $twinColor.hsba, animatableProperty: .saturation, object: object)
                HSBColorChannelPropertyAnimatorBindingElement(title: "Brightness", channel: .brightness, propertyValue: $twinColor.hsba, animatableProperty: .brightness, object: object)
            }
            
        case .RGB:
            CompositeElement(id: Self.colorKeyPath.appending(path: \.rgba), title: "Color", subtitle: "RGB") {
                RGBColorChannelPropertyAnimatorBindingElement(title: "Red", channel: .red, propertyValue: $twinColor.rgba, animatableProperty: .red, object: object)
                RGBColorChannelPropertyAnimatorBindingElement(title: "Green", channel: .green, propertyValue: $twinColor.rgba, animatableProperty: .green, object: object)
                RGBColorChannelPropertyAnimatorBindingElement(title: "Blue", channel: .blue, propertyValue: $twinColor.rgba, animatableProperty: .blue, object: object)
            }
        }
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
