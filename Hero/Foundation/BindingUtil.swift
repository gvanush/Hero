//
//  StateUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.11.21.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                handler(newValue)
                self.wrappedValue = newValue
            }
        )
    }
}
