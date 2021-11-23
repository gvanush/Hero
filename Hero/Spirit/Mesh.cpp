//
//  Mesh.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#include "Mesh.hpp"

#include <CoreFoundation/CoreFoundation.h>

namespace spt {

Mesh::Mesh(const void* buffer, Geometry geometry, unsigned int vertexCount)
: _buffer{buffer}
, _geometry{geometry}
, _vertexCount{vertexCount} {
    assert(buffer);
    _buffer = CFRetain(buffer);
}

Mesh::~Mesh() {
    if(_buffer) {
        CFRelease(_buffer);
    }
}

Mesh::Mesh(Mesh&& mesh) {
    _buffer = mesh._buffer;
    mesh._buffer = nullptr;
    _geometry = mesh._geometry;
    _vertexCount = mesh._vertexCount;
}

Mesh& Mesh::operator=(Mesh&& mesh) {
    if(this != &mesh) {
        _buffer = mesh._buffer;
        mesh._buffer = nullptr;
        _geometry = mesh._geometry;
        _vertexCount = mesh._vertexCount;
    }
    return *this;
}

}
