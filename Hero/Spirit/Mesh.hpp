//
//  Mesh.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

#include <vector>

namespace spt {

class Mesh {
public:
    
    enum class Geometry {
        triangle,
        triangleStrip
    };
    
    Mesh(const void* vertexBuffer, Geometry geometry, const std::vector<const void*>& indexBuffers = std::vector<const void*>{});
    Mesh(Mesh&&);
    Mesh& operator=(Mesh&&) = delete;
    Mesh(const Mesh&) = delete;
    Mesh& operator=(const Mesh&) = delete;
    ~Mesh();
    
    const void* vertexBuffer() const;
    Geometry geometry() const;
    
private:
    const void* _vertexBuffer;
    std::vector<const void*> _indexBuffers;
    Geometry _geometry;
};

inline const void* Mesh::vertexBuffer() const {
    return _vertexBuffer;
}

inline Mesh::Geometry Mesh::geometry() const {
    return _geometry;
}

}
