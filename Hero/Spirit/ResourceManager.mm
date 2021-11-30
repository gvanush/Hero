//
//  ResourceManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.11.21.
//

#include "ResourceManager.h"
#include "ResourceManager.hpp"
#include "ShaderTypes.h"

#include "GHI/Device.hpp"

#include <simd/simd.h>
#define TINYOBJLOADER_IMPLEMENTATION
#include <tiny_obj_loader.h>

#include <iostream>
#include <vector>
#include <unordered_map>

#import <Foundation/Foundation.h>

namespace std {

template<>
struct std::hash<tinyobj::index_t>
{
    std::size_t operator()(const tinyobj::index_t& i) const noexcept
    {
        std::size_t h1 = std::hash<decltype(i.vertex_index)>{}(i.vertex_index);
        std::size_t h2 = std::hash<decltype(i.normal_index)>{}(i.normal_index);
        return h1 ^ (h2 << 1);
    }
};

}

namespace tinyobj {

bool operator==(const index_t& l, const index_t& r) {
    return l.vertex_index == r.vertex_index && l.normal_index == r.normal_index;
}

}

namespace spt {

ResourceManager& ResourceManager::active() {
    static ResourceManager manager;
    return manager;
}

void ResourceManager::loadBasicMeshes() {
    loadMesh("square");
    loadMesh("circle");
    loadMesh("cube");
    loadMesh("cylinder");
    loadMesh("cone");
    loadMesh("sphere");
}

const Mesh& ResourceManager::getMesh(SPTMeshId meshId) {
    assert(meshId < _basicMeshes.size());
    return _basicMeshes[meshId];
}

void ResourceManager::loadMesh(std::string_view name) {
    
    NSString* path = [[NSBundle mainBundle] pathForResource: [NSString stringWithCString: name.data() encoding: NSUTF8StringEncoding] ofType: @"obj"];
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
    
    auto& shapes = reader.GetShapes();
    assert(shapes.size() == 1);
    
    std::vector<MeshVertex> vertexData;
    std::vector<Mesh::IndexType> indexData;
    std::unordered_map<tinyobj::index_t, Mesh::IndexType> addedVertices;
    
    // Loop over shapes
    for (size_t s = 0; s < shapes.size(); s++) {
        // Loop over faces(polygon)
        size_t index_offset = 0;
        for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {
            size_t fv = size_t(shapes[s].mesh.num_face_vertices[f]);
            assert(fv == 3);
            
            // Loop over vertices in the face.
            for (size_t v = 0; v < fv; v++) {
                // access to vertex
                tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
                if(auto it = addedVertices.find(idx); it != addedVertices.end()) {
                    indexData.push_back(it->second);
                    continue;
                }
                
                tinyobj::real_t vx = attrib.vertices[3*size_t(idx.vertex_index)+0];
                tinyobj::real_t vy = attrib.vertices[3*size_t(idx.vertex_index)+1];
                tinyobj::real_t vz = attrib.vertices[3*size_t(idx.vertex_index)+2];
                
                // Check if `normal_index` is zero or positive. negative = no normal data
                assert(idx.normal_index >= 0);
                tinyobj::real_t nx = attrib.normals[3*size_t(idx.normal_index)+0];
                tinyobj::real_t ny = attrib.normals[3*size_t(idx.normal_index)+1];
                tinyobj::real_t nz = attrib.normals[3*size_t(idx.normal_index)+2];
                
                auto index = static_cast<Mesh::IndexType>(vertexData.size());
                indexData.push_back(index);
                vertexData.emplace_back(MeshVertex{simd_float3 {vx, vy, vz}, simd_float3 {nx, ny, nz}});
                addedVertices[idx] = index;
                
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
    
    auto vertexBuffer = ghi::Device::systemDefault().newBuffer(vertexData.data(), vertexData.size() * sizeof(MeshVertex), ghi::StorageMode::shared);
    auto indexBuffer = ghi::Device::systemDefault().newBuffer(indexData.data(), indexData.size() * sizeof(Mesh::IndexType), ghi::StorageMode::shared);
    _basicMeshes.emplace_back(std::unique_ptr<ghi::Buffer>{vertexBuffer}, std::unique_ptr<ghi::Buffer>{indexBuffer});
}

}
