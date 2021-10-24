//
//  UIProgressView+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/3/21.
//

import UIKit

extension UIProgressView {
    
    func setProgress(_ progress: Float, animationSpeed: Float, completion: ((Bool) -> Void)? = nil) {
        let duration = (progress - self.progress) / animationSpeed
        self.progress = progress
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.layoutIfNeeded()
        }, completion: completion)
    }
    
    func startProgress(_ progress: Float = 0.0) {
        self.progress = progress
        self.alpha = 1.0
    }
    
    func completeProgress(animationSpeed: Float, completion: ((Bool) -> Void)? = nil) {
        let duration = (1.0 - self.progress) / animationSpeed
        self.progress = 1.0
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.layoutIfNeeded()
        } completion: { finished in
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0.0
            }
            completion?(finished)
        }
    }
    
}
