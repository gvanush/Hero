//
//  UIImage+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/1/21.
//

import UIKit

extension UIImage {
    
    var textureOrientation: TextureOrientation {
        switch imageOrientation {
        case .up:
            return kTextureOrientationUp
        case .down:
            return kTextureOrientationDown
        case .left:
            return kTextureOrientationLeft
        case .right:
            return kTextureOrientationRight
        case .upMirrored:
            return kTextureOrientationUpMirrored
        case .downMirrored:
            return kTextureOrientationDownMirrored
        case .leftMirrored:
            return kTextureOrientationLeftMirrored
        case .rightMirrored:
            return kTextureOrientationRightMirrored
        @unknown default:
            return kTextureOrientationUp
        }
    }
    
}
