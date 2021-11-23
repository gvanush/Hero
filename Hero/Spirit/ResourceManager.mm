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

#include <iostream>

namespace spt {

ResourceManager& ResourceManager::active() {
    static ResourceManager manager;
    return manager;
}

void ResourceManager::loadBasicMeshes() {
    
    // Unit square
    constexpr float kHalfSize = 0.5f;
    constexpr simd_float3 vertices[] = {
        simd_float3 {-kHalfSize, -kHalfSize, 0.0},
        simd_float3 {kHalfSize, -kHalfSize, 0.0},
        simd_float3 {-kHalfSize, kHalfSize, 0.0},
        simd_float3 {kHalfSize, kHalfSize, 0.0}
    };
    
    id<MTLBuffer> vertexBuffer = [[SPTRenderingContext device] newBufferWithBytes: vertices length: sizeof(vertices) options: MTLResourceCPUCacheModeDefaultCache | MTLResourceStorageModeShared | MTLResourceHazardTrackingModeDefault];
    _basicMeshes.emplace_back((__bridge const void*) vertexBuffer, Mesh::Geometry::triangleStrip);
    
    // Unit circle
    /*NSString* path = [[NSBundle mainBundle] pathForResource: @"circle" ofType: @"obj"];
    assert(path);
    
    std::string inputfile {path.UTF8String};
    
    tinyobj::ObjReader reader;
    tinyobj::ObjReaderConfig reader_config;
    
    if (!reader.ParseFromFile(inputfile, reader_config)) {
      if (!reader.Error().empty()) {
          std::cerr << "TinyObjReader: " << reader.Error();
      }
      exit(1);
    }

    if (!reader.Warning().empty()) {
      std::cout << "TinyObjReader: " << reader.Warning();
    }
    
    auto& attrib = reader.GetAttrib();
    
    
    vertexBuffer = [[SPTRenderingContext device] newBufferWithBytes: attrib.vertices.data() length: attrib.vertices.size() * sizeof(tinyobj::real_t) options: MTLResourceCPUCacheModeDefaultCache | MTLResourceStorageModeShared | MTLResourceHazardTrackingModeDefault];
    _basicMeshes.emplace_back((__bridge const void*) vertexBuffer, Mesh::Geometry::triangleStrip);
    
    auto& shapes = reader.GetShapes();
    assert(shapes.size() == 1);
    
    // Loop over shapes
    for (size_t s = 0; s < shapes.size(); s++) {
      // Loop over faces(polygon)
      size_t index_offset = 0;
      for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {
        size_t fv = size_t(shapes[s].mesh.num_face_vertices[f]);

        // Loop over vertices in the face.
        for (size_t v = 0; v < fv; v++) {
          // access to vertex
          tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
          tinyobj::real_t vx = attrib.vertices[3*size_t(idx.vertex_index)+0];
          tinyobj::real_t vy = attrib.vertices[3*size_t(idx.vertex_index)+1];
          tinyobj::real_t vz = attrib.vertices[3*size_t(idx.vertex_index)+2];

          // Check if `normal_index` is zero or positive. negative = no normal data
//          if (idx.normal_index >= 0) {
//            tinyobj::real_t nx = attrib.normals[3*size_t(idx.normal_index)+0];
//            tinyobj::real_t ny = attrib.normals[3*size_t(idx.normal_index)+1];
//            tinyobj::real_t nz = attrib.normals[3*size_t(idx.normal_index)+2];
//          }

          // Check if `texcoord_index` is zero or positive. negative = no texcoord data
//          if (idx.texcoord_index >= 0) {
//            tinyobj::real_t tx = attrib.texcoords[2*size_t(idx.texcoord_index)+0];
//            tinyobj::real_t ty = attrib.texcoords[2*size_t(idx.texcoord_index)+1];
//          }

          // Optional: vertex colors
          // tinyobj::real_t red   = attrib.colors[3*size_t(idx.vertex_index)+0];
          // tinyobj::real_t green = attrib.colors[3*size_t(idx.vertex_index)+1];
          // tinyobj::real_t blue  = attrib.colors[3*size_t(idx.vertex_index)+2];
        }
        index_offset += fv;

        // per-face material
        shapes[s].mesh.material_ids[f];
      }
    }
    
    id<MTLBuffer> indexBuffer = [[SPTRenderingContext device] newBufferWithBytes:  length: attrib.vertices.size() * sizeof(tinyobj::real_t) options: MTLResourceCPUCacheModeDefaultCache | MTLResourceStorageModeShared | MTLResourceHazardTrackingModeDefault];*/
    
}

const Mesh& ResourceManager::getMesh(SPTMeshId meshId) {
    assert(meshId < _basicMeshes.size());
    return _basicMeshes[meshId];
}

}
