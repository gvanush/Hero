//
//  CommonElements.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


struct CompositeElement<C1, C2, C3, C4, C5>: Element
where C1: Element, C2: Element, C3: Element, C4: Element, C5: Element {
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @Namespace var namespace
    
    var content: (C1, C2, C3, C4, C5)
    
    init(title: String, @ElementBuilder content: () -> (C1, C2, C3, C4, C5)) {
        self.title = title
        self.content = content()
    }
    
}

struct LeafElement<P>: Element where P: ElementProperty {
    
    typealias Property = P
    
    let title: String
    var indexPath: IndexPath!
    var _activeIndexPath: Binding<IndexPath>!
    
    @State var activeProperty: P
    
    @Namespace var namespace
    
    init(title: String, activeProperty: P) {
        self.title = title
        _activeProperty = .init(wrappedValue: activeProperty)
    }
    
}

struct EmptyElement: Element {
    
    
    var title: String {
        fatalError()
    }
    
    var indexPath: IndexPath! {
        get {
            fatalError()
        }
        set {
            
        }
    }
    
    var _activeIndexPath: Binding<IndexPath>! {
        get {
            nil
        }
        set {
            
        }
    }
    
    var namespace: Namespace.ID {
        fatalError()
    }
    
    var content: (Never, Never, Never, Never, Never) {
        get {
            fatalError()
        }
        set {
            
        }
    }
    
    mutating func setupIndexPath(_ indexPath: IndexPath) {
        
    }
    
    mutating func setupActiveIndexPath(_ indexPath: Binding<IndexPath>) {
        
    }
    
    var body: some View {
        EmptyView()
    }
    
}

extension Never: Element {
    
    var title: String {
        fatalError()
    }
    
    var indexPath: IndexPath! {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    var _activeIndexPath: Binding<IndexPath>! {
        get {
            fatalError()
        }
        set {
            fatalError()
        }
    }
    
    var namespace: Namespace.ID {
        fatalError()
    }
    
    var content: (Never, Never, Never, Never, Never) {
        get {
            fatalError()
        }
        set {
            
        }
    }
    
}

extension Never: CaseIterable & Displayable {
    
    public static var allCases = [Never]()
    
}
