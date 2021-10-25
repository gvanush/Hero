//
//  Updater.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/24/21.
//

import Foundation

protocol Updater: AnyObject {
    func start()
    func stop()
    var callback: ((Float) -> Void)? { get set }
}


class TimerUpdater: Updater {
    
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
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) {[unowned self] _ in
            let timestamp = CACurrentMediaTime()
            self.callback?(Float(timestamp - self.lastTimestamp))
            self.lastTimestamp = timestamp
        }
        timer!.tolerance = tolerance
        lastTimestamp = CACurrentMediaTime()
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stop()
    }
    
}

class DisplayLinkUpdater: Updater {
    
    var preferredFramesPerSecond: Int = 0
    var callback: ((Float) -> Void)?
    
    func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(onStep))
        displayLink?.preferredFramesPerSecond = preferredFramesPerSecond
        displayLink!.add(to: .current, forMode: .common)
        lastTimestamp = CACurrentMediaTime()
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    deinit {
        stop()
    }
    
    @objc private func onStep() {
        let timestamp = CACurrentMediaTime()
        self.callback?(Float(timestamp - self.lastTimestamp))
        self.lastTimestamp = timestamp
    }
    
    private var displayLink: CADisplayLink?
    private var lastTimestamp: TimeInterval = 0.0
    
}
