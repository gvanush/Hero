//
//  Logger+Extensions.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/13/20.
//

import os

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }
}
