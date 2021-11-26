//
//  Mesh.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

#include "GHI/Buffer.hpp"

#include <memory>

namespace spt {

class Mesh {
public:
    
    enum class Geometry {
        triangle,
        triangleStrip
    };
    
    Mesh(std::unique_ptr<ghi::Buffer> vertexBuffer, Geometry geometry);
    Mesh(Mesh&&) = default;
    Mesh& operator=(Mesh&&) = default;
    Mesh(const Mesh&) = delete;
    Mesh& operator=(const Mesh&) = delete;
    
    const ghi::Buffer* vertexBuffer() const;
    Geometry geometry() const;
    
private:
    std::unique_ptr<ghi::Buffer> _vertexBuffer;
    Geometry _geometry;
};

inline const ghi::Buffer* Mesh::vertexBuffer() const {
    return _vertexBuffer.get();
}

inline Mesh::Geometry Mesh::geometry() const {
    return _geometry;
}

}
