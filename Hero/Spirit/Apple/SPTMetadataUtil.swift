//
//  SPTMetadataUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.08.22.
//

import Foundation

extension SPTMetadata {
    
    init(tag: Int32, name: String) {
        self.init()
        self.tag = tag
        self.name = name
    }
 
    var name: String {
        get {
            withUnsafePointer(to: _name, { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(kSPTMetadataNameMaxLength) + 1) { charPtr in
                    String(cString: charPtr)
                }
            })
        }
        set {
            withUnsafeMutablePointer(to: &_name) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(kSPTMetadataNameMaxLength) + 1) { charPtr in
                    newValue.utf8CString.withUnsafeBufferPointer { sourceCharPtr in
                        let length = min(sourceCharPtr.count, Int(kSPTMetadataNameMaxLength))
                        charPtr.assign(from: sourceCharPtr.baseAddress!, count: length)
                        charPtr[length] = 0
                    }
                }
            }
        }
    }
    
}
