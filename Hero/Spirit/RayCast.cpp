//
//  RayCast.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.21.
//

#include "RayCast.h"
#include "Scene.hpp"
#include "Transformation.hpp"
#include "ResourceManager.hpp"
#include "SIMDUtil.h"

#include <entt/entt.hpp>

void SPTRayCastableMeshMake(SPTObject object, SPTMeshId meshId) {
    spt::Scene::getRegistry(object).emplace<SPTRayCastableMesh>(object.entity, meshId);
}

SPTRay SPTRayTransform(SPTRay ray, simd_float4x4 matrix) {
    return SPTRay {simd_mul(matrix, simd_make_float4(ray.origin, 1.f)).xyz, simd_mul(matrix, simd_make_float4(ray.direction)).xyz};
}

SPTRayCastResult SPTRayCastScene(SPTSceneHandle sceneHandle, SPTRay ray, float tolerance) {
    
    auto scene = static_cast<spt::Scene*>(sceneHandle);
    auto& registry = scene->registry;
    
    spt::Transformation::update(registry, scene->transformationGroup);
    
    SPTRayCastResult result {kSPTNullObject, INFINITY};
    registry.view<SPTRayCastableMesh>().each([&registry, &result, ray, tolerance, sceneHandle] (auto entity, auto& rayCastableMesh) {
        
        const auto globalMat = registry.get<spt::Transformation>(entity).global;
        SPTRay localRay = SPTRayTransform(ray, simd_inverse(globalMat));
        
        const auto& mesh = spt::ResourceManager::active().getMesh(rayCastableMesh.meshId);
        const auto aabbIntersRes = SPTRayIntersectAABB(localRay, mesh.boundingBox(), tolerance);
        if(aabbIntersRes.intersected) {
            
            for (auto it = mesh.cFaceBegin(); it != mesh.cFaceEnd(); ++it) {
                const auto& face = *it;
                const auto triIntersRes = SPTRayIntersectTriangle(localRay, SPTTriangle{face.v0.position, face.v1.position, face.v2.position}, tolerance);
                if(triIntersRes.intersected && result.rayDirectionFactor > triIntersRes.rayDirectionFactor) {
                    result.object = SPTObject{entity, sceneHandle};
                    result.rayDirectionFactor = triIntersRes.rayDirectionFactor;
                }
            }
            
        }
    });
    
    return result;
}

SPTRayIntersectionResult SPTRayIntersectAABB(SPTRay ray, SPTAABB aabb, float tolerance) {
    
    float t1, t2, tMin = -INFINITY, tMax = INFINITY;
    if(fabs(ray.direction.y) > tolerance) {
        auto invDirY = 1.f / ray.direction.y;
        t1 = (aabb.max.y - ray.origin.y) * invDirY; // Top plane
        t2 = (aabb.min.y - ray.origin.y) * invDirY; // Bottom plane
        if(t1 < t2) {
            tMin = t1; tMax = t2;
        } else {
            tMin = t2; tMax = t1;
        }
        
        if(tMax < 0.f) { return {0.f, false}; };
        
    } else if(ray.origin.y < aabb.min.y || ray.origin.y > aabb.max.y) {
        return {0.f, false};
    }
    
    if(fabs(ray.direction.x) > tolerance) {
        auto invDirX = 1.f / ray.direction.x;
        t1 = (aabb.max.x - ray.origin.x) * invDirX; // Right plane
        t2 = (aabb.min.x - ray.origin.x) * invDirX; // Left plane
        if(t1 < t2) {
            if(t1 > tMin) { tMin = t1; }
            if(t2 < tMax) { tMax = t2; }
        } else {
            if(t2 > tMin) { tMin = t2; }
            if(t1 < tMax) { tMax = t1; }
        }
        
        if(tMin > tMax || tMax < 0.f) { return {0.f, false}; };
        
    } else if(ray.origin.x < aabb.min.x || ray.origin.x > aabb.max.x) {
        return {0.f, false};
    }
    
    if(fabs(ray.direction.z) > tolerance) {
        auto invDirZ = 1.f / ray.direction.z;
        t1 = (aabb.max.z - ray.origin.z) * invDirZ; // Front plane
        t2 = (aabb.min.z - ray.origin.z) * invDirZ; // Back plane
        if(t1 < t2) {
            if(t1 > tMin) { tMin = t1; }
            if(t2 < tMax) { tMax = t2; }
        } else {
            if(t2 > tMin) { tMin = t2; }
            if(t1 < tMax) { tMax = t1; }
        }
        
        if(tMin > tMax || tMax < 0.f) { return {0.f, false}; };
        
    } else if(ray.origin.z < aabb.min.z || ray.origin.z > aabb.max.z) {
        return {0.f, false};
    }
    
    if(tMin > 0.f) { return {tMin, true}; }
    
    return {tMax, true};
}

SPTRayIntersectionResult SPTRayIntersectTriangle(SPTRay ray, SPTTriangle triangle, float tolerance) {
    
    // Backfacing triangles are not culled
    
    const auto e1 = triangle.p1 - triangle.p0;
    const auto e2 = triangle.p2 - triangle.p0;
    const auto q = simd_cross(ray.direction, e2);
    const auto det = simd_dot(e1, q);
    if(fabs(det) <= tolerance) {
        return {0.f, false};
    }
    
    const auto f = 1 / det;
    const auto s = ray.origin - triangle.p0;
    const auto u = f * simd_dot(s, q); // Barycentric coordinate of triangle.p1
    if(u < 0.f) {
        return {0.f, false};
    }
    
    const auto r = simd_cross(s, e1);
    const auto v = f * simd_dot(ray.direction, r); // Barycentric coordinate of triangle.p2
    if(v < 0.f || u + v > 1.f) {
        return {0.f, false};
    }
    const auto t = f * simd_dot(e2, r);
    if(t <= 0.f) {
        return {0.f, false};
    }
    return {t, true};
}
