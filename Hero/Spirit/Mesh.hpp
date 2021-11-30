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
    
    using IndexType = uint16_t;
    
    Mesh(std::unique_ptr<ghi::Buffer> vertexBuffer, std::unique_ptr<ghi::Buffer> indexBuffer);
    Mesh(Mesh&&) = default;
    Mesh& operator=(Mesh&&) = default;
    Mesh(const Mesh&) = delete;
    Mesh& operator=(const Mesh&) = delete;
    
    const ghi::Buffer* vertexBuffer() const;
    const ghi::Buffer* indexBuffer() const;
    
private:
    std::unique_ptr<ghi::Buffer> _vertexBuffer;
    std::unique_ptr<ghi::Buffer> _indexBuffer;
};

inline const ghi::Buffer* Mesh::vertexBuffer() const {
    return _vertexBuffer.get();
}

inline const ghi::Buffer* Mesh::indexBuffer() const {
    return _indexBuffer.get();
}

}
