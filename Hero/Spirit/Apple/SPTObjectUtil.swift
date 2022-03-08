//
//  SPTObjectUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.03.22.
//

import Foundation

extension SPTObject: Equatable {
    
    public static func == (lhs: SPTObject, rhs: SPTObject) -> Bool {
        SPTObjectEqual(lhs, rhs)
    }
    
}
