//
//  Camera.h
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

typedef struct {
    float fovy, aspectRatio, near, far;
} SPTPerspectiveCamera;

SPT_EXTERN_C_BEGIN

SPTPerspectiveCamera SPTMakePerspectiveCamera(SPTObject entity, float fovy, float aspectRatio, float near, float far);

SPTPerspectiveCamera SPTUpdatePerspectiveCameraAspectRatio(SPTObject entity, float aspectRatio);

simd_float3 SPTCameraConvertWorldToViewport(SPTObject cmaeraObject, simd_float3 point, simd_float2 viewportSize);

simd_float3 SPTCameraConvertViewportToWorld(SPTObject cmaeraObject, simd_float3 point, simd_float2 viewportSize);

SPT_EXTERN_C_END
