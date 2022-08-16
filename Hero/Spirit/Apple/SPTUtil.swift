//
//  Util.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.08.22.
//

import Foundation


typealias ObjectWillEmergeCallback<O> = (O) -> Void
typealias ObjectWillChangeCallback<O> = (O) -> Void
typealias ObjectWillPerishCallback = () -> Void
