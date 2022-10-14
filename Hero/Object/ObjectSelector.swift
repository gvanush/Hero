//
//  ObjectSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.03.22.
//

import Foundation


class ObjectSelector {
    
    let object: SPTObject
    
    init?(object: SPTObject?) {
        guard let object = object, !SPTIsNull(object) else {
            return nil
        }

        guard let type = ObjectType(rawValue: SPTMetadataGet(object).tag) else {
            return nil
        }
        
        self.object = object
        switch type {
        case .mesh:
            SPTOutlineLook.make(.init(color: UIColor.objectSelectionColor.rgba, thickness: 5.0, categories: LookCategories.objectSelection.rawValue), object: object)
        case .generator:
            SPTPointLook.make(.init(color: UIColor.objectSelectionColor.rgba, size: 6.0, categories: LookCategories.objectSelection.rawValue), object: object)
            SPTOutlineLook.make(.init(color: UIColor.secondaryObjectSelectionColor.rgba, thickness: 5.0, categories: LookCategories.objectSelection.rawValue), object: object)
        }
    }
    
    deinit {
        let type = ObjectType(rawValue: SPTMetadataGet(object).tag)!
        switch type {
        case .mesh:
            SPTOutlineLook.destroy(object: object)
        case .generator:
            SPTOutlineLook.destroy(object: object)
            SPTPointLook.destroy(object: object)
        }
    }
    
}
