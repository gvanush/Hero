//
//  EmptyElement.swift
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
    
    var content: some Element {
        fatalError()
    }
    
    var sizeAsContent: Int {
        0
    }
    
    var faceView: Never {
        fatalError()
    }
    
    var propertyView: Never {
        fatalError()
    }
    
    var body: some View {
        EmptyView()
    }
    
}
