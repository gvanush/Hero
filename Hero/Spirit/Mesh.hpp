//
//  Mesh.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

#include "Geometry.h"
#include "ShaderTypes.h"
#include "Geometry.h"
#include "GHI/Buffer.hpp"

#include <memory>

namespace spt {

class Mesh {
public:
    
    using Vertex = MeshVertex;
    using ConstVertexIterator = const Vertex*;
    static constexpr size_t faceVertexCount = 3;
    
    struct Face {
        const Vertex& v0;
        const Vertex& v1;
        const Vertex& v2;
    };
    
    class ConstFaceIterator {
    public:
        
        const Face operator*();
        ConstFaceIterator& operator++();
        bool operator!=(const ConstFaceIterator& rhs) const;
        
        const Vertex* _vertices;
        const Vertex::Index* _indicies;
        
    private:
        ConstFaceIterator(const Vertex* vertices, const Vertex::Index* indicies);
        friend class Mesh;
    };
    
    Mesh(std::unique_ptr<ghi::Buffer> vertexBuffer, std::unique_ptr<ghi::Buffer> indexBuffer, const SPTAABB& boundingBox);
    Mesh(Mesh&&) = default;
    Mesh& operator=(Mesh&&) = default;
    Mesh(const Mesh&) = delete;
    Mesh& operator=(const Mesh&) = delete;
    
    ConstVertexIterator cVertexBegin() const;
    ConstVertexIterator cVertexEnd() const;
    
    ConstFaceIterator cFaceBegin() const;
    ConstFaceIterator cFaceEnd() const;
    
    const ghi::Buffer* vertexBuffer() const;
    ghi::UInt vertexCount() const;
    
    const ghi::Buffer* indexBuffer() const;
    ghi::UInt indexCount() const;
    
    const SPTAABB& boundingBox() const;
    size_t faceCount() const;
    
private:
    std::unique_ptr<ghi::Buffer> _vertexBuffer;
    std::unique_ptr<ghi::Buffer> _indexBuffer;
    SPTAABB _boundingBox;
};

inline Mesh::ConstFaceIterator::ConstFaceIterator(const Vertex* vertices, const Vertex::Index* indicies)
: _vertices{vertices}, _indicies(indicies) {
}

inline const Mesh::Face Mesh::ConstFaceIterator::operator*() {
    return Mesh::Face{_vertices[_indicies[0]], _vertices[_indicies[1]], _vertices[_indicies[2]]};
}

inline Mesh::ConstFaceIterator& Mesh::ConstFaceIterator::operator++() {
    _indicies += Mesh::faceVertexCount;
    return *this;
}

inline bool Mesh::ConstFaceIterator::operator!=(const ConstFaceIterator& rhs) const {
    return _vertices != rhs._vertices || _indicies != rhs._indicies;
}

inline Mesh::ConstFaceIterator Mesh::cFaceBegin() const {
    return Mesh::ConstFaceIterator {static_cast<Vertex*>(_vertexBuffer->data()), static_cast<Vertex::Index*>(_indexBuffer->data())};
}

inline Mesh::ConstFaceIterator Mesh::cFaceEnd() const {
    return Mesh::ConstFaceIterator {static_cast<Vertex*>(_vertexBuffer->data()), static_cast<Vertex::Index*>(_indexBuffer->data()) + indexCount()};
}

inline const ghi::Buffer* Mesh::vertexBuffer() const {
    return _vertexBuffer.get();
}

inline ghi::UInt Mesh::vertexCount() const {
    return _vertexBuffer->size() / sizeof(Vertex);
}

inline const ghi::Buffer* Mesh::indexBuffer() const {
    return _indexBuffer.get();
}

inline ghi::UInt Mesh::indexCount() const {
    return _indexBuffer->size() / sizeof(Vertex::Index);
}

inline size_t Mesh::faceCount() const {
    return indexCount() / Mesh::faceVertexCount;
}

inline const SPTAABB& Mesh::boundingBox() const {
    return _boundingBox;
}

inline Mesh::ConstVertexIterator Mesh::cVertexBegin() const {
    return static_cast<Mesh::ConstVertexIterator>(_vertexBuffer->data());
}

inline Mesh::ConstVertexIterator Mesh::cVertexEnd() const {
    return static_cast<Mesh::ConstVertexIterator>(_vertexBuffer->data()) + vertexCount();
}

}
