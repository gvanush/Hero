//
//  SPTAnimatorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 19.07.22.
//

import Foundation

extension SPTAnimatorsSlice: SPTArraySlice {

    public typealias Element = SPTAnimator

}

extension SPTAnimator: Identifiable, Equatable {
    
    init(name: String, bottomLeft: simd_float2 = .init(0.0, 0.0), topRight: simd_float2 = .init(1.0, 1.0)) {
        self.init()
        self.id = kSPTAnimatorInvalidId
        self.bottomLeft = bottomLeft
        self.topRight = topRight
        self.name = name
    }
    
    var name: String {
        get {
            withUnsafePointer(to: _name, { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: kSPTAnimatorNameMaxLength + 1) { charPtr in
                    String(cString: charPtr)
                }
            })
        }
        set {
            withUnsafeMutablePointer(to: &_name) { ptr in
                ptr.withMemoryRebound(to: CChar.self, capacity: kSPTAnimatorNameMaxLength + 1) { charPtr in
                    newValue.utf8CString.withUnsafeBufferPointer { sourceCharPtr in
                        let length = min(sourceCharPtr.count, kSPTAnimatorNameMaxLength)
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
@dynamicMemberLookup
class SPTObservedAniamtor: SPTObservedObject {
    
    private let animatorId: SPTAnimatorId
    internal let binding: SPTObjectBinding<SPTAnimator>
    
    init(animatorId: SPTAnimatorId) {
        self.animatorId = animatorId
        
        binding = SPTObjectBinding(value: SPTAnimatorGet(animatorId), setter: { newValue in
            var updated = newValue
            updated.id = animatorId
            SPTAnimatorUpdate(updated)
        })
        
        SPTAnimatorAddWillChangeListener(animatorId, Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<SPTObservedAniamtor>.fromOpaque(listener).takeUnretainedValue()
            me.binding.onWillChange(newValue: newValue)
        })
        
    }
    
    deinit {
        SPTAnimatorRemoveWillChangeListener(animatorId, Unmanaged.passUnretained(self).toOpaque())
    }
 
    var wrappedValue: SPTAnimator {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<SPTAnimator> {
        binding
    }
    
}
