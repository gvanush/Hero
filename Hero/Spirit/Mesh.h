//
//  Mesh.h
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

#include "Base.h"
#include "Geometry.h"

#include <stdint.h>

SPT_EXTERN_C_BEGIN

typedef uint32_t SPTMeshId;

SPTAABB SPTGetMeshBoundingBox(SPTMeshId meshId);

SPT_EXTERN_C_END
