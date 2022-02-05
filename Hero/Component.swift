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
    weak var parent: Component?
    
    init(title: String, parent: Component?) {
        self.title = title
        self.parent = parent
    }
    
    var id: Component { self }
    var properties: [String]? { nil }
    var activePropertyIndex: Int? {
        set { }
        get { nil }
    }
    var subcomponents: [Component]? { nil }
    
}


protocol ComponentVariant: AnyObject {
    var properties: [String]? { get }
    var activePropertyIndex: Int? { set get }
    var subcomponents: [Component]? { get }
}


protocol ComponentProperty: CaseIterable, Identifiable, Equatable {
    var title: String { get }
}


extension ComponentProperty {
    static var allCaseTitles: [String] {
        Self.allCases.map { $0.title }
    }
}
