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
#include <array>
#include <unordered_map>
#include <unordered_set>

namespace {

struct PosNormHash {
    std::size_t operator()(const tinyobj::index_t& i) const noexcept
    {
        std::size_t h1 = std::hash<decltype(i.vertex_index)>{}(i.vertex_index);
        std::size_t h2 = std::hash<decltype(i.normal_index)>{}(i.normal_index);
        return h1 ^ (h2 << 1);
    }
};

struct FaceVertex {
    tinyobj::index_t index;
    simd_float3 point;
    simd_float3 normal;
};

simd_float3 getPoint(const tinyobj::attrib_t& attrib, size_t index) {
    const auto bi = 3 * index;
    return simd_float3{attrib.vertices[bi], attrib.vertices[bi + 1], attrib.vertices[bi + 2]};
}

simd_float3 getNormal(const tinyobj::attrib_t& attrib, size_t index) {
    const auto bi = 3 * index;
    return simd_normalize(simd_float3{attrib.normals[bi], attrib.normals[bi + 1], attrib.normals[bi + 2]});
}

bool isFrontFacing2D(const std::array<FaceVertex, 3>& face) {
    // CCW order assumed to be front facing
    const auto v1 = face[1].point.xy - face[0].point.xy;
    const auto v2 = face[2].point.xy - face[1].point.xy;
    const auto orthoV1 = simd_float2 {-v1.y, v1.x};
    return simd_dot(orthoV1, v2) > 0.f;
}

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

SPTMeshId ResourceManager::loadMesh(std::string_view path, bool is3D) {
    
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
    
    struct PointNormalRecord {
        std::vector<MeshVertex::Index> vertexIndices;
        simd_float3 normalSum;
    };
    std::unordered_map<int, PointNormalRecord> pointNormalRecords;
    
    std::array<FaceVertex, 3> faceVertices;
    // Loop over faces(polygon)
    size_t index_offset = 0;
    for (size_t f = 0; f < shape.mesh.num_face_vertices.size(); f++) {
        assert(size_t(shape.mesh.num_face_vertices[f]) == 3);
        
        for(auto& faceVertex: faceVertices) {
            tinyobj::index_t idx = shape.mesh.indices[index_offset++];
            assert(idx.normal_index >= 0);
            faceVertex = {idx, getPoint(attrib, idx.vertex_index), getNormal(attrib, idx.normal_index)};
        }
        
        for (const auto& faceVertex: faceVertices) {
            
            if(auto it = addedVertices.find(faceVertex.index); it != addedVertices.end()) {
                indexData.push_back(it->second);
                continue;
            }
            
            // Update bounding box
            boundingBox = SPTAABBExpandToIncludePoint(boundingBox, faceVertex.point);
            
            // Check if `normal_index` is zero or positive. negative = no normal data
            const auto index = static_cast<MeshVertex::Index>(vertexData.size());
            
            MeshVertex vertex {faceVertex.point};
            auto& pointNormalRecord = pointNormalRecords[faceVertex.index.vertex_index];
            if(is3D) {
                vertex.surfaceNormal = faceVertex.normal;
                pointNormalRecord.vertexIndices.push_back(index);
                pointNormalRecord.normalSum += vertex.surfaceNormal;
            } else {
                // In 2D case 'faceVertex.normal' is the normal of the curve/line at faceVertex.point
                assert(faceVertex.point.z == 0.f);
                vertex.surfaceNormal = (isFrontFacing2D(faceVertices) ? 1.f : -1.f) * simd_float3 {0.f, 0.f, 1.f};
                pointNormalRecord.vertexIndices.push_back(index);
                pointNormalRecord.normalSum += faceVertex.normal;
            }
            
            indexData.push_back(index);
            vertexData.emplace_back(vertex);
            addedVertices[faceVertex.index] = index;
    
        }
        
    }
    
    for(auto it = pointNormalRecords.begin(); it != pointNormalRecords.end(); ++it) {
        const auto adjacentSurfaceNormalAverage = simd_normalize(it->second.normalSum / it->second.vertexIndices.size());
        for(const auto vi: it->second.vertexIndices) {
            vertexData[vi].adjacentSurfaceNormalAverage = adjacentSurfaceNormalAverage;
        }
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
            
            const auto prevPoint = getPoint(attrib, prevIdx.vertex_index);
            const auto point = getPoint(attrib, idx.vertex_index);
            
            const auto prevVertex = PolylineVertex{prevPoint};
            auto index0 = static_cast<PolylineVertex::Index>(vertexData.size());
            vertexData.emplace_back(prevVertex);
            auto index1 = static_cast<PolylineVertex::Index>(vertexData.size());
            vertexData.emplace_back(prevVertex);
            
            const auto vertex = PolylineVertex{point};
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

SPTMeshId SPTCreate3DMeshFromFile(const char* path) {
    // Currently immediately loading the mesh, in the future
    // perhaps this needs to be postponed to when the mesh data
    // is actually needed by the engine. Also for each path
    // there must be a unique id
    return spt::ResourceManager::active().loadMesh(path, true);
}

SPTMeshId SPTCreate2DMeshFromFile(const char* path) {
    // Currently immediately loading the mesh, in the future
    // perhaps this needs to be postponed to when the mesh data
    // is actually needed by the engine. Also for each path
    // there must be a unique id
    return spt::ResourceManager::active().loadMesh(path, false);
}

SPTMeshId SPTCreatePolylineFromFile(const char* path) {
    // Currently immediately loading the polyline, in the future
    // perhaps this needs to be postponed to when the polyline data
    // is actually needed by the engine. Also for each path
    // there must be a unique id
    return spt::ResourceManager::active().loadPolyline(path);
}
