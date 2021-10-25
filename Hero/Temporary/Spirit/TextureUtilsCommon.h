//
//  TextureUtilsCommon.h
//  Hero
//
//  Created by Vanush Grigoryan on 1/31/21.
//

#pragma once

typedef enum {
    kTextureOrientationUp = 0,
    kTextureOrientationDown,
    kTextureOrientationLeft,
    kTextureOrientationRight,
    kTextureOrientationUpMirrored,
    kTextureOrientationDownMirrored,
    kTextureOrientationLeftMirrored,
    kTextureOrientationRightMirrored,
} TextureOrientation;

const int kTextureOrientationCount = 8;
