//
//  ScaleUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.12.22.
//

import Foundation

extension SPTScaleModel: CaseIterable, Identifiable, Displayable {
    
    public var id: UInt32 {
        self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .XYZ:
            return "XYZ"
        case .uniform:
            return "Uniform"
        }
    }
    
    public static var allCases: [SPTScaleModel] = [.XYZ, .uniform]
    
}
