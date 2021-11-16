//
//  Camera.h
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#pragma once

#include "Common.h"

#include <simd/simd.h>

typedef struct {
    float fovy, aspectRatio, near, far;
} spt_perspective_camera;

SPT_EXTERN_C_BEGIN

spt_perspective_camera spt_make_perspective_camera(spt_entity entity, float fovy, float aspectRatio, float near, float far);

spt_perspective_camera spt_update_perspective_camera_aspect_ratio(spt_entity entity, float aspectRatio);

SPT_EXTERN_C_END
