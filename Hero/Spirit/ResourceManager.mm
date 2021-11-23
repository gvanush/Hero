//
//  ResourceManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.11.21.
//

#include "ResourceManager.h"
#include "ResourceManager.hpp"

#define TINYOBJLOADER_IMPLEMENTATION
#include <tiny_obj_loader.h>

#import "SPTRenderingContext.h"

namespace spt {

ResourceManager& ResourceManager::active() {
    static ResourceManager manager;
    return manager;
}

void ResourceManager::loadBasicMeshes() {
    constexpr float kHalfSize = 0.5f;
    constexpr simd_float3 vertices[] = {
        simd_float3 {-kHalfSize, -kHalfSize, 0.0},
        simd_float3 {kHalfSize, -kHalfSize, 0.0},
        simd_float3 {-kHalfSize, kHalfSize, 0.0},
        simd_float3 {kHalfSize, kHalfSize, 0.0}
    };
    
    id<MTLBuffer> buffer = [[SPTRenderingContext device] newBufferWithBytes: vertices length: sizeof(vertices) options: MTLResourceCPUCacheModeDefaultCache | MTLResourceStorageModeShared | MTLResourceHazardTrackingModeDefault];
    _basicMeshes.emplace_back((__bridge const void*) buffer, Mesh::Geometry::triangleStrip, sizeof(vertices) / sizeof(simd_float3));
}

const Mesh& ResourceManager::getMesh(SPTMeshId meshId) {
    assert(meshId < _basicMeshes.size());
    return _basicMeshes[meshId];
}

}
