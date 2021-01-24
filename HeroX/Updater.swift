//
//  Updater.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/24/21.
//

import Foundation

protocol Updater: class {
    func start()
    func stop()
    var callback: ((Float) -> Void)? { get set }
}


class BasicUpdater: Updater {
    
    var timeInterval: TimeInterval
    var tolerance: TimeInterval
    var callback: ((Float) -> Void)?
    
    init(timeInterval: TimeInterval, tolerance: TimeInterval, callback: ((Float) -> Void)? = nil) {
        self.timeInterval = timeInterval
        self.tolerance = tolerance
        self.callback = callback
    }
    
    private var timer: Timer?
    private var lastTimestamp: TimeInterval = 0.0
    
    func start() {
        lastTimestamp = CACurrentMediaTime()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) {[unowned self] _ in
            let timestamp = CACurrentMediaTime()
            self.callback?(Float(timestamp - self.lastTimestamp))
            self.lastTimestamp = timestamp
        }
        timer!.tolerance = tolerance
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
    
}
