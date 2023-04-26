//
//  MoveToolModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import Foundation


class MoveToolModel: ObservableObject {
    
    struct Item {
        var disclosedElementsData: [ComponentElementData]?
    }
    
    @Published private var items = [SPTObject : Item]()
    
    subscript (object: SPTObject) -> Item! {
        get {
            items[object, default: .init()]
        }
        set {
            items[object] = newValue
        }
    }
    
}
