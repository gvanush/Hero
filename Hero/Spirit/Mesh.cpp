//
//  Mesh.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#include "Mesh.hpp"
#include "Mesh.h"
#include "ResourceManager.hpp"

namespace spt {

Mesh::Mesh(std::unique_ptr<ghi::Buffer> vertexBuffer, std::unique_ptr<ghi::Buffer> indexBuffer, const SPTAABB& boundingBox)
: _vertexBuffer{std::move(vertexBuffer)}
, _indexBuffer{std::move(indexBuffer)}
, _boundingBox{boundingBox} {
}

}

SPTAABB SPTGetMeshBoundingBox(SPTMeshId meshId) {
    return spt::ResourceManager::active().getMesh(meshId).boundingBox();
}
