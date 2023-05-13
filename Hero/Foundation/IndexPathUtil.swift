//
//  IndexPathUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 21.04.23.
//

import Foundation

extension IndexPath {
    
    func bumpingLast(_ count: Int = 1) -> IndexPath {
        var indexPath = self
        indexPath[indexPath.endIndex - 1] += count
        return indexPath
    }
    
}
