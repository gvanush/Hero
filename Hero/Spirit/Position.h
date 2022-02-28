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

void SPTPositionMake(SPTObject object, SPTPosition position);
void SPTPositionMakeXYZ(SPTObject object, simd_float3 xyz);
void SPTPositionMakeSpherical(SPTObject object, SPTSphericalPosition spherical);

void SPTPositionUpdate(SPTObject object, SPTPosition position);

SPTPosition SPTPositionGet(SPTObject object);
simd_float3 SPTPositionGetXYZ(SPTObject object);

simd_float3 SPTPositionConvertSphericalToXYZ(SPTSphericalPosition sphericalPosition);

void SPTPositionAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTPositionRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTPositionRemoveWillChangeListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
