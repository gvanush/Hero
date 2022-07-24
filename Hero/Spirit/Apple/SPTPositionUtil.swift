//
//  SPTPositionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTPosition: Equatable {
    
    public static func == (lhs: SPTPosition, rhs: SPTPosition) -> Bool {
        SPTPositionEqual(lhs, rhs)
    }
    
    public static func willChangeSink(object: SPTObject, _ callback: @escaping (SPTPosition) -> Void) -> SPTAnyCancellable {
        
        let cancellable = SPTCancellableListener(callback: callback) { listener in
            SPTPositionRemoveWillChangeListener(object, Unmanaged.passUnretained(listener).toOpaque())
        }
        
        SPTPositionAddWillChangeListener(object, Unmanaged.passUnretained(cancellable).toOpaque(), { listener, newValue  in
            let me = Unmanaged<SPTCancellableListener<SPTPosition>>.fromOpaque(listener).takeUnretainedValue()
            me.callback(newValue)
        })
        
        return cancellable
    }
}


@propertyWrapper
@dynamicMemberLookup
class SPTObservedPosition: SPTObservedObject {
    
    private let object: SPTObject
    internal let binding: SPTObjectBinding<SPTPosition>
    
    init(object: SPTObject) {
        self.object = object
        
        binding = SPTObjectBinding(value: SPTPositionGet(object), setter: { newValue in
            SPTPositionUpdate(object, newValue)
        })
        
        SPTPositionAddWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<SPTObservedPosition>.fromOpaque(listener).takeUnretainedValue()
            me.binding.onWillChange(newValue: newValue)
        })
        
    }
    
    deinit {
        SPTPositionRemoveWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
 
    var wrappedValue: SPTPosition {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<SPTPosition> {
        binding
    }
    
}
