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

SPTPerspectiveCamera SPTMakePerspectiveCamera(SPTObject object, float fovy, float aspectRatio, float near, float far);

SPTPerspectiveCamera SPTUpdatePerspectiveCameraAspectRatio(SPTObject object, float aspectRatio);

simd_float3 SPTCameraConvertWorldToViewport(SPTObject cameraObject, simd_float3 point, simd_float2 viewportSize);

simd_float3 SPTCameraConvertViewportToWorld(SPTObject cameraObject, simd_float3 point, simd_float2 viewportSize);

SPT_EXTERN_C_END