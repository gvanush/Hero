//
//  SPTObjectUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.03.22.
//

import Foundation

extension SPTObject: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(sceneHandle)
        hasher.combine(entity.rawValue)
    }
    
    public static func == (lhs: SPTObject, rhs: SPTObject) -> Bool {
        SPTObjectEqual(lhs, rhs)
    }
    
}

extension SPTEntity: Hashable {
    
}
