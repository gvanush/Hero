//
//  ShadeElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.05.23.
//

import SwiftUI


struct ShadeElement: Element {
    
    static let keyPath = \SPTMeshLook.shading.blinnPhong
    static let shininessKeyPath = keyPath.appending(path: \.shininess)
    
    enum Property: Int, ElementProperty {
        case shininess
    }
    
    let object: SPTObject
    
    @ObjectElementActiveProperty var activeProperty: Property
    @StateObject private var colorModel: SPTObservableComponentProperty<SPTMeshLook, SPTColorModel>
    
    init(object: SPTObject) {
        self.object = object
        _activeProperty = .init(object: object, elementId: Self.keyPath)
        _colorModel = .init(wrappedValue: .init(object: object, keyPath: \.shading.blinnPhong.color.model))
    }
    
    var content: some Element {
        switch colorModel.value {
        case .HSB:
            HSBAColorElement(object: object, keyPath: Self.keyPath.appending(path: \.color))
        case .RGB:
            RGBAColorElement(object: object, keyPath: Self.keyPath.appending(path: \.color))
        }
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .shininess:
                ObjectFloatPropertySlider(object: object, keyPath: Self.shininessKeyPath)
            }
        }
        .tint(.primarySelectionColor)
    }
    
    var id: some Hashable {
        Self.keyPath
    }
    
    var title: String {
        "Shade"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
