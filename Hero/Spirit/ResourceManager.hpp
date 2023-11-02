//
//  ResourceManager.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

#include "ResourceManager.h"
#include "Mesh.hpp"
#include "Mesh.h"
#include "Polyline.hpp"
#include "Polyline.h"

#include <vector>
#include <string_view>
#include <cassert>

namespace spt {

class ResourceManager {
public:
    
    static ResourceManager& active();
    
    SPTMeshId loadMesh(std::string_view path, bool is3D);
    SPTPolylineId loadPolyline(std::string_view path);
    
    const Mesh& getMesh(SPTMeshId meshId);
    const Polyline& getPolyline(SPTPolylineId polylineId);
    
private:
    
    ResourceManager() = default;
    ResourceManager(const ResourceManager&) = delete;
    ResourceManager(ResourceManager&&) = delete;
    ResourceManager& operator=(const ResourceManager&) = delete;
    ResourceManager& operator=(ResourceManager&&) = delete;
    
    std::vector<Mesh> _meshes;
    std::vector<Polyline> _polylines;
    
};

inline const Mesh& ResourceManager::getMesh(SPTMeshId meshId) {
    assert(meshId < _meshes.size());
    return _meshes[meshId];
}

inline const Polyline& ResourceManager::getPolyline(SPTPolylineId polylineId) {
    assert(polylineId < _polylines.size());
    return _polylines[polylineId];
}

}
