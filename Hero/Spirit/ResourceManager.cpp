//
//  ResourceManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.11.21.
//

#include "ResourceManager.h"
#include "ResourceManager.hpp"
#include "Geometry.h"
#include "ShaderTypes.h"
#include "SIMDUtil.h"

#include "GHI/Device.hpp"

#include <simd/simd.h>
#define TINYOBJLOADER_IMPLEMENTATION
#include <tiny_obj_loader.h>

#include <iostream>
#include <vector>
#include <unordered_map>
#include <unordered_set>

namespace {

struct PosHash {
    std::size_t operator()(const tinyobj::index_t& i) const noexcept {
        return std::hash<decltype(i.vertex_index)>{}(i.vertex_index);
    }
};

struct PosNormHash {
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

SPTMeshId ResourceManager::loadMesh(std::string_view path) {
    
    tinyobj::ObjReader reader;
    tinyobj::ObjReaderConfig reader_config;
    
    if (!reader.ParseFromFile(std::string{path}, reader_config)) {
        if (!reader.Error().empty()) {
            std::cerr << "TinyObjReader: " << reader.Error();
        }
        exit(1);
    }

    if (!reader.Warning().empty()) {
        std::cout << "TinyObjReader: " << reader.Warning();
    }
    
    auto& attrib = reader.GetAttrib();
    
    assert(reader.GetShapes().size() == 1);
    const auto& shape = reader.GetShapes()[0];
    
    std::vector<MeshVertex> vertexData;
    std::vector<MeshVertex::Index> indexData;
    std::unordered_map<tinyobj::index_t, MeshVertex::Index, PosNormHash> addedVertices;
    SPTAABB boundingBox {float3_infinity, float3_negative_infinity};
    
    // Loop over faces(polygon)
    size_t index_offset = 0;
    for (size_t f = 0; f < shape.mesh.num_face_vertices.size(); f++) {
        size_t fv = size_t(shape.mesh.num_face_vertices[f]);
        assert(fv == 3);
        
        // Loop over vertices in the face.
        for (size_t v = 0; v < fv; v++) {
            // access to vertex
            tinyobj::index_t idx = shape.mesh.indices[index_offset + v];
            if(auto it = addedVertices.find(idx); it != addedVertices.end()) {
                indexData.push_back(it->second);
                continue;
            }
            
            tinyobj::real_t px = attrib.vertices[3*size_t(idx.vertex_index)+0];
            tinyobj::real_t py = attrib.vertices[3*size_t(idx.vertex_index)+1];
            tinyobj::real_t pz = attrib.vertices[3*size_t(idx.vertex_index)+2];
            
            // Update bounding box
            boundingBox = SPTAABBExpandToIncludePoint(boundingBox, simd_float3{px, py, pz});
            
            // Check if `normal_index` is zero or positive. negative = no normal data
            assert(idx.normal_index >= 0);
            tinyobj::real_t nx = attrib.normals[3*size_t(idx.normal_index)+0];
            tinyobj::real_t ny = attrib.normals[3*size_t(idx.normal_index)+1];
            tinyobj::real_t nz = attrib.normals[3*size_t(idx.normal_index)+2];
            
            auto index = static_cast<MeshVertex::Index>(vertexData.size());
            indexData.push_back(index);
            vertexData.emplace_back(MeshVertex{simd_float3 {px, py, pz}, simd_float3 {nx, ny, nz}});
            addedVertices[idx] = index;
    
        }
        index_offset += fv;
        
    }
    
    auto vertexBuffer = ghi::Device::systemDefault().newBuffer(vertexData.data(), vertexData.size() * sizeof(MeshVertex), ghi::StorageMode::shared);
    auto indexBuffer = ghi::Device::systemDefault().newBuffer(indexData.data(), indexData.size() * sizeof(MeshVertex::Index), ghi::StorageMode::shared);
    _meshes.emplace_back(std::unique_ptr<ghi::Buffer>{vertexBuffer}, std::unique_ptr<ghi::Buffer>{indexBuffer}, boundingBox);
    return static_cast<SPTMeshId>(_meshes.size() - 1);
}

SPTPolylineId ResourceManager::loadPolyline(std::string_view path) {
    
    tinyobj::ObjReader reader;
    tinyobj::ObjReaderConfig reader_config;
    
    if (!reader.ParseFromFile(std::string{path}, reader_config)) {
        if (!reader.Error().empty()) {
            std::cerr << "TinyObjReader: " << reader.Error();
        }
        exit(1);
    }

    if (!reader.Warning().empty()) {
        std::cout << "TinyObjReader: " << reader.Warning();
    }
    
    auto& attrib = reader.GetAttrib();
    
    assert(reader.GetShapes().size() == 1);
    const auto& shape = reader.GetShapes()[0];
    
    std::vector<PolylineVertex> vertexData;
    std::vector<PolylineVertex::Index> indexData;
    SPTAABB boundingBox {float3_infinity, float3_negative_infinity};
    
    // Loop over polylines
    size_t index_offset = 0;
    for (size_t f = 0; f < shape.lines.num_line_vertices.size(); f++) {
        size_t lv = size_t(shape.lines.num_line_vertices[f]);
        
        // Loop over vertices in the polyline starting from second one
        for (size_t v = 1; v < lv; v++) {
            
            // Each new vertex brings one line segment which is expressed
            // by 4 vertices (2 triangles) on GPU
            
            const auto prevIdx = shape.lines.indices[index_offset + v - 1];
            const auto idx = shape.lines.indices[index_offset + v];
            
            tinyobj::real_t prevPx = attrib.vertices[3*size_t(prevIdx.vertex_index)+0];
            tinyobj::real_t prevPy = attrib.vertices[3*size_t(prevIdx.vertex_index)+1];
            tinyobj::real_t prevPz = attrib.vertices[3*size_t(prevIdx.vertex_index)+2];
            
            tinyobj::real_t px = attrib.vertices[3*size_t(idx.vertex_index)+0];
            tinyobj::real_t py = attrib.vertices[3*size_t(idx.vertex_index)+1];
            tinyobj::real_t pz = attrib.vertices[3*size_t(idx.vertex_index)+2];
            
            const auto prevVertex = PolylineVertex{simd_float3 {prevPx, prevPy, prevPz}};
            auto index0 = static_cast<PolylineVertex::Index>(vertexData.size());
            vertexData.emplace_back(prevVertex);
            auto index1 = static_cast<PolylineVertex::Index>(vertexData.size());
            vertexData.emplace_back(prevVertex);
            
            const auto vertex = PolylineVertex{simd_float3 {px, py, pz}};
            auto index2 = static_cast<PolylineVertex::Index>(vertexData.size());
            vertexData.emplace_back(vertex);
            auto index3 = static_cast<PolylineVertex::Index>(vertexData.size());
            vertexData.emplace_back(vertex);
            
            indexData.insert(indexData.end(), {index0, index1, index2, index0, index2, index3});
            
            // Update bounding box
            boundingBox = SPTAABBExpandToIncludePoint(boundingBox, prevVertex.position);
            boundingBox = SPTAABBExpandToIncludePoint(boundingBox, vertex.position);
            
        }
        index_offset += lv;
        
    }
    
    auto vertexBuffer = ghi::Device::systemDefault().newBuffer(vertexData.data(), vertexData.size() * sizeof(PolylineVertex), ghi::StorageMode::shared);
    auto indexBuffer = ghi::Device::systemDefault().newBuffer(indexData.data(), indexData.size() * sizeof(PolylineVertex::Index), ghi::StorageMode::shared);
    _polylines.emplace_back(std::unique_ptr<ghi::Buffer>{vertexBuffer}, std::unique_ptr<ghi::Buffer>{indexBuffer}, boundingBox);
    return static_cast<SPTPolylineId>(_polylines.size() - 1);
    
}

}

SPTMeshId SPTCreateMeshFromFile(const char* path) {
    // Currently immediately loading the mesh, in the future
    // perhaps this needs to be postponed to when the mesh data
    // is actually needed by the engine. Also for each path
    // there must be a unique id
    return spt::ResourceManager::active().loadMesh(path);
}

SPTMeshId SPTCreatePolylineFromFile(const char* path) {
    // Currently immediately loading the polyline, in the future
    // perhaps this needs to be postponed to when the polyline data
    // is actually needed by the engine. Also for each path
    // there must be a unique id
    return spt::ResourceManager::active().loadPolyline(path);
}
