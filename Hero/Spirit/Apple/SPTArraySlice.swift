//
//  SPTArraySlice.swift
//  Hero
//
//  Created by Vanush Grigoryan on 19.07.22.
//

import Foundation
import UIKit

protocol SPTArraySlice: RandomAccessCollection where Indices == Range<Int>, SubSequence == Self {
    
    init(_data: UnsafePointer<Element>?, startIndex: Index, endIndex: Index)
    
    var _data: UnsafePointer<Element>? { get }
    
}

extension SPTArraySlice {
    
    public var indices: Range<Int> {
        startIndex..<endIndex
    }
    
    public subscript(bounds: Range<Int>) -> Self {
        guard indices.lowerBound <= bounds.lowerBound && bounds.upperBound <= indices.upperBound else { fatalError() }
        return Self(_data: _data, startIndex: bounds.startIndex, endIndex: bounds.endIndex)
    }
    
    public subscript(position: Int) -> Element {
        guard indices.contains(position) else { fatalError() }
        return _data![position]
    }
    
    public func formIndex(after i: inout Int) {
        i = i + 1
    }
    
    public func formIndex(before i: inout Int) {
        i = i - 1
    }
    
    
}

