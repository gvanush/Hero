//
//  Mesh.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

namespace spt {

class Mesh {
public:
    
    enum class Geometry {
        triangle,
        triangleStrip
    };
    
    Mesh(const void* buffer, Geometry geometry, unsigned int vertexCount);
    Mesh(Mesh&&);
    Mesh& operator=(Mesh&&);
    Mesh(const Mesh&) = delete;
    Mesh& operator=(const Mesh&) = delete;
    ~Mesh();
    
    const void* buffer() const;
    Geometry geometry() const;
    unsigned int vertexCount() const;
    
private:
    const void* _buffer;
    Geometry _geometry;
    unsigned int _vertexCount;
};

inline const void* Mesh::buffer() const {
    return _buffer;
}

inline Mesh::Geometry Mesh::geometry() const {
    return _geometry;
}

inline unsigned int Mesh::vertexCount() const {
    return _vertexCount;
}

}
