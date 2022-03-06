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
            SPTOutlineViewMake(object, UIColor.objectSelectionColor.rgba, 5.0)
        case .generator:
            SPTPointViewMake(object, SPTPointView(color: UIColor.objectSelectionColor.rgba, size: 6.0))
            SPTOutlineViewMake(object, UIColor.secondaryObjectSelectionColor.rgba, 5.0)
        }
    }
    
    deinit {
        let type = ObjectType(rawValue: SPTMetadataGet(object).tag)!
        switch type {
        case .mesh:
            SPTOutlineViewDestroy(object)
        case .generator:
            SPTOutlineViewDestroy(object)
            SPTPointViewDestroy(object)
        }
    }
    
}
