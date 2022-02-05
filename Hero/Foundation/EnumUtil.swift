//
//  EnumUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation


extension RawRepresentable {
    init?(rawValue: Self.RawValue?) {
        if let rawValue = rawValue {
            self.init(rawValue: rawValue)
        } else {
            return nil
        }
    }
}
