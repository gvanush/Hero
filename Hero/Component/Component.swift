//
//  Component.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.02.22.
//

import Foundation
import SwiftUI


class Component: Identifiable, ObservableObject {
    
    let title: String
    private(set) weak var parent: Component?
    
    init(title: String, parent: Component?) {
        self.title = title
        self.parent = parent
    }
    
    var id: ObjectIdentifier { ObjectIdentifier(self) }
    var properties: [String]? { nil }
    var selectedPropertyIndex: Int? {
        set { }
        get { nil }
    }
    var subcomponents: [Component]? { nil }
    
    func accept(_ provider: EditComponentViewProvider) -> AnyView? {
        nil
    }
    
}

class BasicComponent<PT>: Component where PT: RawRepresentable & CaseIterable & Displayable, PT.RawValue == Int {
    
    @Published var selectedProperty: PT?
    
    init(title: String, selectedProperty: PT?, parent: Component?) {
        self.selectedProperty = selectedProperty
        super.init(title: title, parent: parent)
    }
    
    override var properties: [String]? {
        PT.allCaseDisplayNames
    }
    
    override var selectedPropertyIndex: Int? {
        set {
            selectedProperty = .init(rawValue: newValue)
        }
        get {
            selectedProperty?.rawValue
        }
    }
    
}


class MultiVariantComponent: Component {
    
    var variants: [Component]! { nil }
    var activeVariantIndex: Int! { set { } get { nil } }
    
    var activeVariant: Component {
        variants[activeVariantIndex]
    }
    
    override var properties: [String]? {
        activeVariant.properties
    }
    
    override var selectedPropertyIndex: Int? {
        set {
            activeVariant.selectedPropertyIndex = newValue
        }
        get {
            activeVariant.selectedPropertyIndex
        }
    }
    
    override var subcomponents: [Component]? {
        activeVariant.subcomponents
    }
}
