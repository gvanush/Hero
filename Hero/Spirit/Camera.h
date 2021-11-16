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

SPT_EXTERN_C_END
