//
//  SPTAnimatorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.07.22.
//

import Foundation

enum PanAnimatorSignal: Identifiable, Displayable {
    
    case horizontal
    case vertical
    
    var id: Self {
        self
    }
}

extension SPTAnimator {
    
    func boundsOffsetOnScreenSize(_ screenSize: CGSize) -> CGSize {
        let midX = (bottomLeft.x + topRight.x) * 0.5
        let midY = (bottomLeft.y + topRight.y) * 0.5
        return .init(width: CGFloat(midX - 0.5) * screenSize.width, height: CGFloat(0.5 - midY) * screenSize.height)
    }
    
    func boundsSizeOnScreenSize(_ screenSize: CGSize) -> CGSize {
        let normWidth = topRight.x - bottomLeft.x
        let normHeight = topRight.y - bottomLeft.y
        return .init(width: CGFloat(normWidth) * screenSize.width, height: CGFloat(normHeight) * screenSize.height)
    }
    
}
