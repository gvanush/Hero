//
//  MultiVariantComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.02.22.
//

import Foundation
import Combine


enum ComponentVoidProperty: Int, DistinctValueSet, RawRepresentable, Displayable {
    case __dummy
}


protocol ComponentVariant2: ObservableObject {
    
    associatedtype PT: DistinctValueSet & RawRepresentable & Displayable = ComponentVoidProperty where PT.RawValue == Int
    var selected: PT? { set get }
    
    var subcomponents: [Component]? { get }
    
}

extension ComponentVariant2 {
    
    var selected: PT? {
        set { }
        get { nil }
    }
    
    var properties: [String]? { PT.allCaseDisplayNames }
    
    var activePropertyIndex: Int? {
        set {
            selected = .init(rawValue: newValue)
        }
        get {
            selected?.rawValue
        }
    }
    
    var subcomponents: [Component]? { nil }
    
}


protocol ComponentVariant: ObservableObject {
    
    associatedtype VT: Equatable
    static var tag: VT { get }
    
    init()
    
    associatedtype PT: DistinctValueSet & RawRepresentable & Displayable = ComponentVoidProperty where PT.RawValue == Int
    var selected: PT? { set get }
    
    var subcomponents: [Component]? { get }
    
}

extension ComponentVariant {
    
    var selected: PT? {
        set { }
        get { nil }
    }
    
    var properties: [String]? { PT.allCaseDisplayNames }
    
    var activePropertyIndex: Int? {
        set {
            selected = .init(rawValue: newValue)
        }
        get {
            selected?.rawValue
        }
    }
    
    var subcomponents: [Component]? { nil }
    
}


class MultiVariantComponent2<V1, V2>: Component
where V1: ComponentVariant, V2: ComponentVariant, V1.VT == V2.VT
{
    
    @Published var variantTag: V1.VT
    
    let variant1: V1
    private var variant1Cancellable: AnyCancellable?
    let variant2: V2
    private var variant2Cancellable: AnyCancellable?
    
    init(title: String, variantTag: V1.VT, parent: Component?) {
        self.variantTag = variantTag
        
        variant1 = V1()
        variant2 = V2()
        
        super.init(title: title, parent: parent)
        
        variant1Cancellable = variant1.objectWillChange.sink(receiveValue: { _ in
            self.onVariantWillChange(variant: V1.tag)
        })
        variant2Cancellable = variant2.objectWillChange.sink(receiveValue: { _ in
            self.onVariantWillChange(variant: V2.tag)
        })
        
        
    }
    
    private func onVariantWillChange(variant: V1.VT) -> Void {
        if self.variantTag == variant {
            objectWillChange.send()
        }
    }
    
    override var properties: [String]? {
        switch self.variantTag {
        case V1.tag:
            return variant1.properties
        case V2.tag:
            return variant2.properties
        default:
            return nil
        }
    }
    
    override var activePropertyIndex: Int? {
        set {
            switch self.variantTag {
            case V1.tag:
                variant1.activePropertyIndex = newValue
            case V2.tag:
                variant2.activePropertyIndex = newValue
            default:
                break
            }
        }
        get {
            switch self.variantTag {
            case V1.tag:
                return variant1.activePropertyIndex
            case V2.tag:
                return variant2.activePropertyIndex
            default:
                return nil
            }
        }
    }
    
    override var subcomponents: [Component]? {
        switch self.variantTag {
        case V1.tag:
            return variant1.subcomponents
        case V2.tag:
            return variant2.subcomponents
        default:
            return nil
        }
    }
    
}


class MultiVariantComponent4<V1, V2, V3, V4>: Component
where V1: ComponentVariant, V2: ComponentVariant, V3: ComponentVariant, V4: ComponentVariant, V1.VT == V2.VT, V1.VT == V3.VT, V1.VT == V4.VT
{
    
    @Published var variantTag: V1.VT
    
    let variant1: V1
    private var variant1Cancellable: AnyCancellable?
    let variant2: V2
    private var variant2Cancellable: AnyCancellable?
    let variant3: V3
    private var variant3Cancellable: AnyCancellable?
    let variant4: V4
    private var variant4Cancellable: AnyCancellable?
    
    init(title: String, variantTag: V1.VT, parent: Component?) {
        self.variantTag = variantTag
        
        variant1 = V1()
        variant2 = V2()
        variant3 = V3()
        variant4 = V4()
        
        super.init(title: title, parent: parent)
        
        variant1Cancellable = variant1.objectWillChange.sink(receiveValue: { _ in
            self.onVariantWillChange(variant: V1.tag)
        })
        variant2Cancellable = variant2.objectWillChange.sink(receiveValue: { _ in
            self.onVariantWillChange(variant: V2.tag)
        })
        variant3Cancellable = variant3.objectWillChange.sink(receiveValue: { _ in
            self.onVariantWillChange(variant: V3.tag)
        })
        variant4Cancellable = variant4.objectWillChange.sink(receiveValue: { _ in
            self.onVariantWillChange(variant: V4.tag)
        })
        
    }
    
    private func onVariantWillChange(variant: V1.VT) -> Void {
        if self.variantTag == variant {
            objectWillChange.send()
        }
    }
    
    override var properties: [String]? {
        switch self.variantTag {
        case V1.tag:
            return variant1.properties
        case V2.tag:
            return variant2.properties
        case V3.tag:
            return variant3.properties
        case V4.tag:
            return variant4.properties
        default:
            return nil
        }
    }
    
    override var activePropertyIndex: Int? {
        set {
            switch self.variantTag {
            case V1.tag:
                variant1.activePropertyIndex = newValue
            case V2.tag:
                variant2.activePropertyIndex = newValue
            case V3.tag:
                variant3.activePropertyIndex = newValue
            case V4.tag:
                variant4.activePropertyIndex = newValue
            default:
                break
            }
        }
        get {
            switch self.variantTag {
            case V1.tag:
                return variant1.activePropertyIndex
            case V2.tag:
                return variant2.activePropertyIndex
            case V3.tag:
                return variant3.activePropertyIndex
            case V4.tag:
                return variant4.activePropertyIndex
            default:
                return nil
            }
        }
    }
    
    override var subcomponents: [Component]? {
        switch self.variantTag {
        case V1.tag:
            return variant1.subcomponents
        case V2.tag:
            return variant2.subcomponents
        case V3.tag:
            return variant3.subcomponents
        case V4.tag:
            return variant4.subcomponents
        default:
            return nil
        }
    }
    
}
