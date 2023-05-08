//
//  BasicToolModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import Foundation


class BasicToolModel: ObservableObject {
    
    struct ObjectData {
        var disclosedElementsData: [ElementData]?
    }
    
    @Published private var items = [SPTObject : ObjectData]()
    
    subscript (object: SPTObject) -> ObjectData! {
        get {
            items[object, default: .init()]
        }
        set {
            items[object] = newValue
        }
    }
    
}
