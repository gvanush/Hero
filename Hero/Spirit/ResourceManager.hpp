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
    
    static ResourceManager& active();
    
    SPTMeshId loadMesh(std::string_view path);
    
    const Mesh& getMesh(SPTMeshId meshId);
    
private:
    
    ResourceManager() = default;
    ResourceManager(const ResourceManager&) = delete;
    ResourceManager(ResourceManager&&) = delete;
    ResourceManager& operator=(const ResourceManager&) = delete;
    ResourceManager& operator=(ResourceManager&&) = delete;
    
    std::vector<Mesh> _basicMeshes;
    
};

}
