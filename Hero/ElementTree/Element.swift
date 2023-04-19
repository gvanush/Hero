//
//  Element.swift
//  Hero
//
//  Created by Vanush Grigoryan on 18.04.23.
//

import SwiftUI

typealias ElementProperty = Hashable & CaseIterable & Displayable

protocol Element: View {
    
    var title: String { get }
    
    associatedtype C1: Element = EmptyElement
    associatedtype C2: Element = EmptyElement
    associatedtype C3: Element = EmptyElement
    associatedtype C4: Element = EmptyElement
    associatedtype C5: Element = EmptyElement
    
    var content: (C1, C2, C3, C4, C5) { get }
    
    associatedtype Property: ElementProperty = Never
    var activeProperty: Property { get }
    
    func nodeView(indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) -> ElementNodeView<Self>?
}

extension Element {
    
    var body: some View {
        Text(title)
            .font(Font.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: true, vertical: false)
    }
    
    func nodeView(indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) -> ElementNodeView<Self>? {
        .init(element: self, indexPath: indexPath, activeIndexPath: activeIndexPath)
    }
    
}

extension Element where Property == Never {
    
    var activeProperty: Property {
        fatalError()
    }
    
}

extension Element where C1 == EmptyElement, C2 == EmptyElement, C3 == EmptyElement, C4 == EmptyElement, C5 == EmptyElement {
    
    var content: (C1, C2, C3, C4, C5) {
        (.init(), .init(), .init(), .init(), .init())
    }
    
}


struct CompositeElement<C1, C2, C3, C4, C5>: Element
where C1: Element, C2: Element, C3: Element, C4: Element, C5: Element {
    
    let title: String
    let content: (C1, C2, C3, C4, C5)
    
    init(title: String, @ElementBuilder content: () -> (C1, C2, C3, C4, C5)) {
        self.title = title
        self.content = content()
    }
    
    var activeProperty: Never {
        fatalError()
    }
    
}

struct LeafElement<P>: Element where P: ElementProperty {
    
    typealias Property = P
    
    let title: String
    var activeProperty: P
    
    init(title: String, activeProperty: P) {
        self.title = title
        self.activeProperty = activeProperty
    }
    
    var content: some Element {
        EmptyElement()
    }
    
}

struct EmptyElement: Element {
    
    var title: String {
        fatalError()
    }
    
    var content: (Never, Never, Never, Never, Never) {
        fatalError()
    }
    
    var body: some View {
        EmptyView()
    }
    
    func nodeView(indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) -> ElementNodeView<Self>? {
        nil
    }
    
}

extension Never: Element {
    
    var title: String {
        fatalError()
    }
    
    var content: (Never, Never, Never, Never, Never) {
        fatalError()
    }
    
    var activeProperty: Never {
        fatalError()
    }
}

extension Never: CaseIterable & Displayable {
    
    public static var allCases = [Never]()
    
}
