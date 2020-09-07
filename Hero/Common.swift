//
//  Common.swift
//  Hero
//
//  Created by Vanush Grigoryan on 9/5/20.
//

import Foundation

enum OptionalResource<T> {
    case notLoaded
    case none
    case some(T)
}
