//
//  UniformScaleElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.05.23.
//

import SwiftUI

struct UniformScaleElement: Element {
    
    static let keyPath = \SPTScale.uniform
    
    enum Property: Int, ElementProperty {
        case value
    }
    
    let object: SPTObject
    
    @StateObject private var uniform: SPTObservableComponentProperty<SPTScale, Float>
    @ObjectElementActiveProperty var activeProperty: Property
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    init(object: SPTObject) {
        self.object = object
        _uniform = .init(wrappedValue: .init(object: object, keyPath: Self.keyPath))
        _activeProperty = .init(object: object, elementId: Self.keyPath)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .value:
                ObjectFloatPropertySelector(object: object, id: Self.keyPath, value: $uniform.value, formatter: Formatters.scale)
            }
        }
        .tint(.primarySelectionColor)
    }
    
    var optionsView: some View {
        ObjectScaleModelSelector(object: object)
    }
    
    var id: some Hashable {
        Self.keyPath
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
