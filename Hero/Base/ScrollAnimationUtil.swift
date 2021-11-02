//
//  ScrollTimingParams.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.11.21.
//

import Foundation

// MARK: Reference
// https://developer.apple.com/videos/play/wwdc2018/803/
// https://medium.com/@esskeetit/scrolling-mechanics-of-uiscrollview-142adee1142c

struct ScrollAnimationUtil {
    
    static let normalDecelerationRate = 0.998
    static let fastDecelerationRate = 0.99
    
    var decelerationRate: Double {
        willSet {
            assert(newValue < 1 && newValue > 0)
            updateDecelerationRateFactor()
        }
    }
    var threshold: Double
    var initialValue: Double = 0
    var initialSpeed: Double = 0
    
    init(decelerationRate: Double = Self.normalDecelerationRate, threshold: Double = 0.1) {
        self.decelerationRate = decelerationRate
        self.threshold = threshold
        updateDecelerationRateFactor()
    }
    
    var destination: Double {
        initialValue + initialSpeed / decelerationRateFactor
    }
    
    var duration: TimeInterval {
        TimeInterval(log(-decelerationRateFactor * threshold / abs(initialSpeed)) / decelerationRateFactor)
    }
    
    func value(at time: TimeInterval) -> Double {
        initialValue - (pow(decelerationRate, CGFloat(1000 * time)) - 1) / decelerationRateFactor * initialSpeed
    }
    
    static func distance(initialSpeed: Double, decelerationRate: Double) -> Double {
        (initialSpeed / 1000.0) * decelerationRate / (1.0 - decelerationRate)
    }
    
    static func initialSpeed(distance: Double, decelerationRate: Double) -> Double {
        1000.0 * distance * (1 - decelerationRate) / decelerationRate
    }
    
    private mutating func updateDecelerationRateFactor() {
        // NOTE: nearly equal to 1000 * log(decelerationRate) when decelerationRate is near to 1
        decelerationRateFactor = 1000 * (decelerationRate - 1) / decelerationRate
    }
    
    private var decelerationRateFactor: Double = 0
    
}
