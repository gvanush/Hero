//
//  MeshView.h
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
    simd_float4 color;
    SPTMeshId meshId;
} SPTMeshView;

SPTMeshView SPTMakeMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color);
SPTMeshView SPTGetMeshView(SPTObject object);

SPT_EXTERN_C_END
