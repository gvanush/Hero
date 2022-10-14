//
//  SPTAnimatorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 19.07.22.
//

import Foundation
import Combine


extension SPTAnimatorsSlice: SPTArraySlice {

    public typealias Element = SPTAnimator

}

extension SPTAnimator: Identifiable, Equatable {
    
    init(name: String, source: SPTAnimatorSource) {
        self.init()
        self.id = kSPTAnimatorInvalidId
        self.source = source
        self.name = name
    }
    
    var name: String {
        get {
            withUnsafePointer(to: _name, { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(kSPTAnimatorNameMaxLength) + 1) { charPtr in
                    String(cString: charPtr)
                }
            })
        }
        set {
            withUnsafeMutablePointer(to: &_name) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: Int(kSPTAnimatorNameMaxLength) + 1) { charPtr in
                    newValue.utf8CString.withUnsafeBufferPointer { sourceCharPtr in
                        let length = min(sourceCharPtr.count, Int(kSPTAnimatorNameMaxLength))
                        charPtr.assign(from: sourceCharPtr.baseAddress!, count: length)
                        charPtr[length] = 0
                    }
                }
            }
        }
    }
    
    public static func == (lhs: SPTAnimator, rhs: SPTAnimator) -> Bool {
        SPTAnimatorEqual(lhs, rhs)
    }
    
}

@propertyWrapper
class SPTObservedAnimator {
    
    private let animatorId: SPTAnimatorId
    
    weak var publisher: ObservableObjectPublisher?
    
    init(animatorId: SPTAnimatorId) {
        self.animatorId = animatorId
        
        SPTAnimatorAddWillChangeListener(animatorId, Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<SPTObservedAnimator>.fromOpaque(listener).takeUnretainedValue()
            me.publisher?.send()
        })
        
    }
    
    deinit {
        SPTAnimatorRemoveWillChangeListener(animatorId, Unmanaged.passUnretained(self).toOpaque())
    }
 
    var wrappedValue: SPTAnimator {
        set {
            var updated = newValue
            updated.id = animatorId
            SPTAnimatorUpdate(updated)
        }
        get { SPTAnimatorGet(animatorId) }
    }
    
}
