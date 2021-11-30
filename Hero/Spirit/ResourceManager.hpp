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

#include <vector>
#include <string_view>

namespace spt {

class ResourceManager {
public:
    
    // NOTE: Currently iusing single intance however
    // ultimately resource manager will be per project
    static ResourceManager& active();
    
    void loadBasicMeshes();
    
    const Mesh& getMesh(SPTMeshId meshId);
    
private:
    void loadMesh(std::string_view name);
    
    ResourceManager() = default;
    ResourceManager(const ResourceManager&) = delete;
    ResourceManager(ResourceManager&&) = delete;
    ResourceManager& operator=(const ResourceManager&) = delete;
    ResourceManager& operator=(ResourceManager&&) = delete;
    
    std::vector<Mesh> _basicMeshes;
    
};

}
