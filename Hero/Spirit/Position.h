//
//  Position.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>


SPT_EXTERN_C_BEGIN

typedef enum {
    SPTPositionVariantTagXYZ,
    SPTPositionVariantTagSpherical,
} __attribute__((enum_extensibility(closed))) SPTPositionVariantTag;

typedef struct {
    simd_float3 center;
    float radius;
    float longitude; // relative to z
    float latitude; // relative to y
} SPTSphericalPosition;

typedef struct {
    SPTPositionVariantTag variantTag;
    union {
        simd_float3 xyz;
        SPTSphericalPosition spherical;
    };
} SPTPosition;

void SPTMakePosition(SPTObject object, SPTPosition position);

void SPTUpdatePosition(SPTObject object, SPTPosition position);

SPTPosition SPTGetPosition(SPTObject object);

void SPTAddPositionWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemovePositionWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemovePositionWillChangeListener(SPTObject object, SPTComponentListener listener);

simd_float3 SPTGetPositionFromSphericalPosition(SPTSphericalPosition sphericalPosition);

SPT_EXTERN_C_END
