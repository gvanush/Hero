//
//  DisplayRefreshSync.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.11.21.
//

import Foundation

class DisplayRefreshSync {
    
    var update: ((TimeInterval) -> Void)
    var completion: (() -> Void)?
    
    private var displayLink: CADisplayLink!
    private var duration: TimeInterval = 0.0
    private var startTimestamp: TimeInterval = 0.0
    
    init(update: @escaping ((TimeInterval) -> Void), completion: (() -> Void)? = nil) {
        self.update = update
        self.completion = completion
        displayLink = CADisplayLink(target: self, selector: #selector(onStep))
        displayLink.add(to: .current, forMode: .common)
        displayLink.isPaused = true
    }
    
    func start(duration: TimeInterval) {
        assert(!isActive)
        startTimestamp = CACurrentMediaTime()
        self.duration = duration
        displayLink.isPaused = false
    }
    
    var isActive: Bool {
        !displayLink.isPaused
    }
    
    func stop() {
        displayLink.isPaused = true
    }
    
    @objc private func onStep() {
        let timestamp = CACurrentMediaTime()
        var passeedTime = timestamp - self.startTimestamp
        if passeedTime > duration {
            passeedTime = duration
        }
        update(passeedTime)
        if passeedTime == duration {
            stop()
            completion?()
        }
    }
    
}
