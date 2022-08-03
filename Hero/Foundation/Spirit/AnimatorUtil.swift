//
//  SPTAnimatorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.07.22.
//

import Foundation


extension SPTPanAnimatorSourceAxis: Identifiable, CaseIterable, Displayable {
    
    public var id: Self {
        self
    }
    
    var displayName: String {
        switch self {
        case .horizontal:
            return "Horizontal"
        case .vertical:
            return "Vertical"
        }
    }
    
    public static var allCases: [SPTPanAnimatorSourceAxis] {
        [.horizontal, .vertical]
    }
    
}


extension SPTAnimatorSourcePan {
    
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
