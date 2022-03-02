//
//  SPTOrientationUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


@propertyWrapper
@dynamicMemberLookup
class SPTObservedOrientation: SPTObservedComponent {
    
    private let object: SPTObject
    internal let binding: SPTComponentBinding<SPTOrientation>
    
    init(object: SPTObject) {
        self.object = object
        
        binding = SPTComponentBinding(value: SPTOrientationGet(object), setter: { newValue in
            SPTOrientationUpdate(object, newValue)
        })
        
        SPTOrientationAddWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque(), { observer, newValue  in
            let me = Unmanaged<SPTObservedOrientation>.fromOpaque(observer!).takeUnretainedValue()
            me.binding.onWillChange(newValue: newValue)
        })
        
    }
    
    deinit {
        SPTOrientationRemoveWillChangeListener(object, Unmanaged.passUnretained(self).toOpaque())
    }
 
    var wrappedValue: SPTOrientation {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTComponentBinding<SPTOrientation> {
        binding
    }
    
}


extension SPTOrientation: Equatable {
    
    public static func == (lhs: SPTOrientation, rhs: SPTOrientation) -> Bool {
        SPTOrientationEqual(lhs, rhs)
    }
    
}
