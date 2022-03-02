//
//  SPTPositionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


@propertyWrapper
@dynamicMemberLookup
class SPTObservedPosition: SPTObservedComponent {
    
    private let object: SPTObject
    internal let binding: SPTComponentBinding<SPTPosition>
    
    init(object: SPTObject) {
        self.object = object
        
        binding = SPTComponentBinding(value: SPTPositionGet(object), setter: { newValue in
            SPTPositionUpdate(object, newValue)
        })
        
        SPTPositionAddWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer, newValue  in
            let me = Unmanaged<SPTObservedPosition>.fromOpaque(observer!).takeUnretainedValue()
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
    
    var projectedValue: SPTComponentBinding<SPTPosition> {
        binding
    }
    
}


extension SPTPosition: Equatable {
    
    public static func == (lhs: SPTPosition, rhs: SPTPosition) -> Bool {
        SPTPositionEqual(lhs, rhs)
    }
    
}
