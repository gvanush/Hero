//
//  MeshRenderable.h
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#pragma once

#include "Base.h"
#include "Mesh.h"

SPT_EXTERN_C_BEGIN

typedef struct {
    SPTMeshId meshId;
} SPTMeshRenderable;

SPTMeshRenderable SPTMakeMeshRenderable(SPTObject object, SPTMeshId meshId);

SPT_EXTERN_C_END
