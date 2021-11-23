//
//  Mesh.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#include "Mesh.hpp"

#include <CoreFoundation/CoreFoundation.h>

namespace spt {

Mesh::Mesh(const void* vertexBuffer, Geometry geometry, const std::vector<const void*>& indexBuffers)
: _vertexBuffer{vertexBuffer}
, _indexBuffers{indexBuffers}
, _geometry{geometry} {
    assert(vertexBuffer);
    CFRetain(vertexBuffer);
    for(auto indexBuffer: _indexBuffers) {
        CFRetain(indexBuffer);
    }
}

Mesh::~Mesh() {
    if(_vertexBuffer) {
        CFRelease(_vertexBuffer);
    }
    for(auto indexBuffer: _indexBuffers) {
        CFRelease(indexBuffer);
    }
}

Mesh::Mesh(Mesh&& mesh) {
    _vertexBuffer = mesh._vertexBuffer;
    mesh._vertexBuffer = nullptr;
    _indexBuffers = std::move(mesh._indexBuffers);
    _geometry = mesh._geometry;
}

}
