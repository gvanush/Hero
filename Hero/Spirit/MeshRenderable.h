//
//  MeshRenderable.h
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#pragma once

#include "Base.h"
#include "Mesh.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef struct {
    SPTMeshId meshId;
    simd_float4 color;
} SPTMeshRenderable;

SPTMeshRenderable SPTMakeMeshRenderable(SPTObject object, SPTMeshId meshId, simd_float4 color);

SPT_EXTERN_C_END
