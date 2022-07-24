//
//  SPTScaleUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


@propertyWrapper
@dynamicMemberLookup
class SPTObservedScale: SPTObservedObject {
    
    private let object: SPTObject
    internal let binding: SPTObjectBinding<SPTScale>
    
    init(object: SPTObject) {
        self.object = object
        
        binding = SPTObjectBinding(value: SPTScaleGet(object), setter: { newValue in
            SPTScaleUpdate(object, newValue)
        })
        
        SPTScaleAddWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { listener, newValue  in
            let me = Unmanaged<SPTObservedScale>.fromOpaque(listener).takeUnretainedValue()
            me.binding.onWillChange(newValue: newValue)
        })
        
    }
    
    deinit {
        SPTScaleRemoveWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
 
    var wrappedValue: SPTScale {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<SPTScale> {
        binding
    }
    
}


extension SPTScale: Equatable {
    
    public static func == (lhs: SPTScale, rhs: SPTScale) -> Bool {
        SPTScaleEqual(lhs, rhs)
    }
    
}
