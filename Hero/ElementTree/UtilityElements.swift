//
//  UtilityElements.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.04.23.
//

import SwiftUI


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
    
    var content: TupleElement<(Never, Never, Never, Never, Never)> {
        fatalError()
    }
    
    var nodeCount: Int {
        0
    }
    
    var body: some View {
        EmptyView()
    }
    
}

struct TupleElement<T> : Element {

    public var value: T

    init(_ value: T) {
        self.value = value
    }
    
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
 
    var content: TupleElement<(Never, Never, Never, Never, Never)> {
        fatalError()
    }
    
    var nodeCount: Int {
        fatalError()
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
    
    var content: TupleElement<(Never, Never, Never, Never, Never)> {
        fatalError()
    }
    
    var nodeCount: Int {
        fatalError()
    }
    
}

extension Never: CaseIterable & Displayable {
    
    public static var allCases = [Never]()
    
}
