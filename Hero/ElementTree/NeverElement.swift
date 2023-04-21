//
//  NeverElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 21.04.23.
//

import SwiftUI


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
    
    var content: some Element {
        fatalError()
    }
    
    var sizeAsContent: Int {
        fatalError()
    }
    
    var faceView: Never {
        fatalError()
    }
    
    var propertyView: Never {
        fatalError()
    }
    
    var body: Never {
        fatalError()
    }
    
}

extension Never: CaseIterable & Displayable {
    
    public static var allCases = [Never]()
    
}
