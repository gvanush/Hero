//
//  GroupView.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/2/21.
//

import UIKit

class GroupView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden else { return nil }
        
        for subview in subviews.reversed() {
            let pointInSubview = subview.convert(point, from: self)
            if subview.bounds.contains(pointInSubview), let hitTestView = subview.hitTest(pointInSubview, with: event) {
                return hitTestView
            }
        }
        
        return nil
    }
}
