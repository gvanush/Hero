//
//  SPTScaleUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


@propertyWrapper
@dynamicMemberLookup
class SPTObservedScale: SPTObservedComponent {
    
    private let object: SPTObject
    internal let binding: SPTComponentBinding<SPTScale>
    
    init(object: SPTObject) {
        self.object = object
        
        binding = SPTComponentBinding(value: SPTScaleGet(object), setter: { newValue in
            SPTScaleUpdate(object, newValue)
        })
        
        SPTScaleAddWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer, newValue  in
            let me = Unmanaged<SPTObservedScale>.fromOpaque(observer!).takeUnretainedValue()
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
    
    var projectedValue: SPTComponentBinding<SPTScale> {
        binding
    }
    
}


extension SPTScale: Equatable {
    
    public static func == (lhs: SPTScale, rhs: SPTScale) -> Bool {
        SPTScaleEqual(lhs, rhs)
    }
    
}
