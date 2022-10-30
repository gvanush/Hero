//
//  MeshLook.h
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
} __attribute__((enum_extensibility(open))) SPTMeshShadingType;

typedef struct {
    SPTMeshShadingType type;
    union {
        SPTPlainColorMaterial plainColor;
        SPTPhongMaterial blinnPhong;
    };
} SPTMeshShading;

typedef struct {
    SPTMeshShading shading;
    SPTMeshId meshId;
    SPTLookCategories categories;
} SPTMeshLook;

bool SPTMeshLookEqual(SPTMeshLook lhs, SPTMeshLook rhs);

bool SPTMeshShadingEqual(SPTMeshShading lhs, SPTMeshShading rhs);

void SPTMeshLookMake(SPTObject object, SPTMeshLook meshLook);

void SPTMeshLookUpdate(SPTObject object, SPTMeshLook meshLook);

void SPTMeshLookDestroy(SPTObject object);

SPTMeshLook SPTMeshLookGet(SPTObject object);

const SPTMeshLook* _Nullable SPTMeshLookTryGet(SPTObject object);

bool SPTMeshLookExists(SPTObject object);

SPT_EXTERN_C_END
