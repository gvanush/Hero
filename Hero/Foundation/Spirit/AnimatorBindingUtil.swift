//
//  AnimatorBindingUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

import Foundation


extension SPTAnimatorBinding {
    
    var valueAt0InDegrees: Float {
        get {
            toDegrees(radians: valueAt0)
        }
        set {
            valueAt0 = toRadians(degrees: newValue)
        }
    }
    
    var valueAt1InDegrees: Float {
        get {
            toDegrees(radians: valueAt1)
        }
        set {
            valueAt1 = toRadians(degrees: newValue)
        }
    }
    
}


struct SPTAnimatorBindingPropertyId<AP, PT>: Hashable where AP: SPTAnimatableProperty {
    let animatableProperty: AP
    let propertyKeyPath: KeyPath<SPTAnimatorBinding, PT>
}
