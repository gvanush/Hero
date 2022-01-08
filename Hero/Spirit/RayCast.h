//
//  RayCast.h
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.21.
//

#pragma once

#include "Base.h"
#include "Geometry.h"
#include "Mesh.h"

SPT_EXTERN_C_BEGIN

// MARK: SPTRayCastableMesh
typedef struct {
    SPTMeshId meshId;
} SPTRayCastableMesh;

SPTRayCastableMesh SPTMakeRayCastableMesh(SPTObject object, SPTMeshId meshId);

// MARK: SPTRay
typedef struct {
    simd_float3 origin;
    simd_float3 direction;
} SPTRay;

SPTRay SPTTransformRay(SPTRay ray, simd_float4x4 matrix);

typedef struct {
    SPTObject object;
    float rayDirectionFactor;
} SPTRayCastResult;

SPTRayCastResult SPTRayCastScene(SPTSceneHandle scene, SPTRay ray, float tolerance);

typedef struct {
    float rayDirectionFactor;
    bool intersected;
} SPTRayIntersectionResult;

SPTRayIntersectionResult SPTIntersectRayAABB(SPTRay ray, SPTAABB aabb, float tolerance);

SPTRayIntersectionResult SPTIntersectRayTriangle(SPTRay ray, SPTTriangle triangle, float tolerance);

SPT_EXTERN_C_END