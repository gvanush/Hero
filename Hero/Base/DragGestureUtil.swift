//
//  DragGestureUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.11.21.
//

import SwiftUI

extension DragGesture.Value {
    
    func scrollInitialSpeedX(decelerationRate: Double) -> CGFloat {
        ScrollAnimationUtil.initialSpeed(distance: predictedEndLocation.x - location.x, decelerationRate: decelerationRate)
    }
    
    func scrollInitialSpeedY(decelerationRate: Double) -> CGFloat {
        ScrollAnimationUtil.initialSpeed(distance: predictedEndLocation.y - location.y, decelerationRate: decelerationRate)
    }
    
}
