//
//  PositionPropertyAnimatorBindingElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 12.05.23.
//

import Foundation


protocol PositionPropertyAnimatorBindingElement: PropertyAnimatorBindingElement {
    
    var point0Object: SPTObject! { get }
    
    var point1Object: SPTObject! { get }
    
}

extension PositionPropertyAnimatorBindingElement {
    
    func onActivePropertyChange() {
        var point0Look = SPTPointLook.get(object: point0Object)
        var point1Look = SPTPointLook.get(object: point1Object)
        
        switch activeProperty {
        case .valueAt0:
            point0Look.color = activeGuideColor.rgba
            point1Look.color = guideColor.rgba
            sceneViewModel.focusedObject = point0Object
        case .valueAt1:
            point0Look.color = guideColor.rgba
            point1Look.color = activeGuideColor.rgba
            sceneViewModel.focusedObject = point1Object
        }
        
        SPTPointLook.update(point0Look, object: point0Object)
        SPTPointLook.update(point1Look, object: point1Object)
    }
    
}
