//
//  MeshView.h
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#pragma once

#include "Base.h"
#include "Mesh.h"
#include "Materials.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTMeshShadingPlainColor,
    SPTMeshShadingBlinnPhong
} SPTMeshShading;

typedef struct {
    simd_float4 color;
} SPTPlainColor;

typedef struct {
    union {
        struct { simd_float4 color; } plainColor;
        PhongMaterial blinnPhong;
    };
    SPTMeshShading shading;
    SPTMeshId meshId;
} SPTMeshView;

SPTMeshView SPTMakePlainColorMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color);
SPTMeshView SPTMakeBlinnPhongMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color, float specularRoughness);
SPTMeshView SPTGetMeshView(SPTObject object);

SPT_EXTERN_C_END
