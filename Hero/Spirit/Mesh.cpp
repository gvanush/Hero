//
//  Mesh.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#include "Mesh.hpp"

#include <CoreFoundation/CoreFoundation.h>

namespace spt {

Mesh::Mesh(std::unique_ptr<ghi::Buffer> vertexBuffer, std::unique_ptr<ghi::Buffer> indexBuffer)
: _vertexBuffer{std::move(vertexBuffer)}
, _indexBuffer{std::move(indexBuffer)} {
}

}
