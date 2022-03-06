//
//  RayCast.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.21.
//

#include "RayCast.h"
#include "MeshView.h"
#include "Generator.hpp"
#include "Scene.hpp"
#include "Transformation.hpp"
#include "ResourceManager.hpp"
#include "SIMDUtil.h"

#include <entt/entt.hpp>


namespace spt {

namespace  {

// Assumes that the 'point' is on the 'ray' line
float computeRayDirectionFactor(const SPTRay& ray, const simd_float3& point) {
    auto i = SPTMaxComponentIndex(ray.direction);
    return (point[i] - ray.origin[i]) / ray.direction[i];
}

struct RayCastResult {
    float rayDirectionFactor;
    bool intersected;
};

RayCastResult rayCastMesh(const Mesh& mesh, const SPTRay& ray, float tolerance) {
    
    RayCastResult result {INFINITY, false};
    if(SPTRayIntersectAABB(ray, mesh.boundingBox(), tolerance).intersected) {
        for (auto it = mesh.cFaceBegin(); it != mesh.cFaceEnd(); ++it) {
            const auto& face = *it;
            const auto triIntersRes = SPTRayIntersectTriangle(ray, SPTTriangle{face.v0.position, face.v1.position, face.v2.position}, tolerance);
            if(triIntersRes.intersected && result.rayDirectionFactor > triIntersRes.rayDirectionFactor) {
                result.rayDirectionFactor = triIntersRes.rayDirectionFactor;
                result.intersected = true;
            }
        }
    }
    return result;
}

RayCastResult tryRayCastMeshView(Registry& registry, SPTEntity entity, const SPTRay& ray, float tolerance) {
    
    RayCastResult result {INFINITY, false};
    const auto meshView = registry.try_get<SPTMeshView>(entity);
    if(!meshView) {
        return result;
    }
    
    const auto& globalMat = registry.get<spt::Transformation>(entity).global;
    SPTRay localRay = SPTRayTransform(ray, simd_inverse(globalMat));
    
    const auto& mesh = spt::ResourceManager::active().getMesh(meshView->meshId);
    
    const auto meshRayCastResult = rayCastMesh(mesh, localRay, tolerance);
    
    if(meshRayCastResult.intersected) {
        
        const auto& point = SPTRayGetPoint(localRay, meshRayCastResult.rayDirectionFactor);
        auto globalPoint = simd_mul(globalMat, simd_make_float4(point, 1.f)).xyz;
        
        auto rayFactor = computeRayDirectionFactor(ray, globalPoint);;
        
        if(result.rayDirectionFactor > rayFactor) {
            result.rayDirectionFactor = rayFactor;
            result.intersected = true;
        }
    }
    
    return result;
}

RayCastResult tryRayCastGenerator(Registry& registry, SPTEntity entity, const SPTRay& ray, float tolerance) {
    
    RayCastResult result {INFINITY, false};
    const auto generator = registry.try_get<spt::Generator>(entity);
    if(!generator) {
        return result;
    }
    const auto& mesh = spt::ResourceManager::active().getMesh(generator->base.sourceMeshId);
    
    // TODO: Refactor to access only generator items
    Transformation::forEachChild(registry, entity, [&registry, &ray, &mesh, &result, tolerance] (auto childEntity, const auto& childTran) {
        
        SPTRay localRay = SPTRayTransform(ray, simd_inverse(childTran.global));
        const auto meshRayCastResult = rayCastMesh(mesh, localRay, tolerance);
        
        if(meshRayCastResult.intersected) {
            
            const auto& point = SPTRayGetPoint(localRay, meshRayCastResult.rayDirectionFactor);
            auto globalPoint = simd_mul(childTran.global, simd_make_float4(point, 1.f)).xyz;
            
            auto rayFactor = computeRayDirectionFactor(ray, globalPoint);;
            
            if(result.rayDirectionFactor > rayFactor) {
                result.rayDirectionFactor = rayFactor;
                result.intersected = true;
            }
        }
    });
    
    return result;
}

}

}

void SPTRayCastableMake(SPTObject object) {
    spt::Scene::getRegistry(object).emplace<SPTRayCastable>(object.entity);
}

SPTRay SPTRayTransform(SPTRay ray, simd_float4x4 matrix) {
    return SPTRay {simd_mul(matrix, simd_make_float4(ray.origin, 1.f)).xyz, simd_mul(matrix, simd_make_float4(ray.direction)).xyz};
}

simd_float3 SPTRayGetPoint(SPTRay ray, float factor) {
    return ray.origin + factor * ray.direction;
}

SPTRayCastResult SPTRayCastScene(SPTSceneHandle sceneHandle, SPTRay ray, float tolerance) {
    
    auto scene = static_cast<spt::Scene*>(sceneHandle);
    auto& registry = scene->registry;
    
    spt::Transformation::update(registry, scene->transformationGroup);
    
    SPTRayCastResult result {kSPTNullObject, INFINITY};
    registry.view<SPTRayCastable>().each([&registry, &result, ray, tolerance, sceneHandle] (auto entity, auto& rayCastableMesh) {
        
        if(const auto& subResult = spt::tryRayCastMeshView(registry, entity, ray, tolerance);
           subResult.intersected && result.rayDirectionFactor > subResult.rayDirectionFactor) {
            result.object = SPTObject {entity, sceneHandle};
            result.rayDirectionFactor = subResult.rayDirectionFactor;
        }
        
        if(const auto& subResult = spt::tryRayCastGenerator(registry, entity, ray, tolerance);
           subResult.intersected && result.rayDirectionFactor > subResult.rayDirectionFactor) {
            result.object = SPTObject {entity, sceneHandle};
            result.rayDirectionFactor = subResult.rayDirectionFactor;
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
