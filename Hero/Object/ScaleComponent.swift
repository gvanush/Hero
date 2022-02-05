//
//  ScaleComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import Combine


class ScaleComponent: Component {
    
    enum VariantTag {
        case nonuniform
        case uniform
    }
    
    @Published var activeVariantTag = VariantTag.nonuniform
    
    private let nonuniformScaleVariant = NonuniformScaleComponentVariant()
    private var nonuniformScaleVariantCancellable: AnyCancellable?
    private let uniformScaleVariant = UniformScaleComponentVariant()
    private var uniformScaleVariantCancellable: AnyCancellable?
    
    init(parent: Component?) {
        super.init(title: "Scale", parent: parent)
        
        nonuniformScaleVariantCancellable = nonuniformScaleVariant.objectWillChange.sink(receiveValue: {
            self.onVariantWillChange(tag: .nonuniform)
        })
        uniformScaleVariantCancellable = uniformScaleVariant.objectWillChange.sink(receiveValue: {
            self.onVariantWillChange(tag: .uniform)
        })
    }
    
    private func onVariantWillChange(tag: VariantTag) -> Void {
        if activeVariantTag == tag {
            objectWillChange.send()
        }
    }
    
    private var activeVariant: ComponentVariant {
        switch activeVariantTag {
        case .nonuniform:
            return nonuniformScaleVariant
        case .uniform:
            return uniformScaleVariant
        }
    }
    
    override var properties: [String]? {
        activeVariant.properties
    }
    
    override var activePropertyIndex: Int? {
        set { activeVariant.activePropertyIndex = newValue }
        get { activeVariant.activePropertyIndex }
    }
    
}


class NonuniformScaleComponentVariant: ComponentVariant, ObservableObject {
    
    @Published var activeAxis: Axis? = .x
    
    var properties: [String]? {
        Axis.allCaseTitles
    }
    
    var activePropertyIndex: Int? {
        set { activeAxis = .init(rawValue: newValue) }
        get { activeAxis?.rawValue }
    }
    
    var subcomponents: [Component]? { nil }
    
}

class UniformScaleComponentVariant: ComponentVariant, ObservableObject {
    
    enum Property: Int, ComponentProperty {
        case scale
        
        var id: Self { self }
        
        var title: String {
            switch self {
            case .scale:
                return "Scale"
            }
        }
    }
    
    @Published var activeProperty: Property? = .scale
    
    var properties: [String]? {
        Property.allCaseTitles
    }
    
    var activePropertyIndex: Int? {
        set { activeProperty = .init(rawValue: newValue) }
        get { activeProperty?.rawValue }
    }
    
    var subcomponents: [Component]? { nil }
    
}
