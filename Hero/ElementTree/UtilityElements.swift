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
    
    var content: (Never, Never, Never, Never, Never) {
        get {
            fatalError()
        }
        set {
            
        }
    }
    
    var nodeCount: Int {
        0
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
    
    var nodeCount: Int {
        fatalError()
    }
    
}

extension Never: CaseIterable & Displayable {
    
    public static var allCases = [Never]()
    
}
