//
//  Mesh.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.11.21.
//

#pragma once

#include "Geometry.h"
#include "GHI/Buffer.hpp"
#include "ShaderTypes.h"
#include "Geometry.h"

#include <memory>

namespace spt {

class Mesh {
public:
    
    using VertexType = MeshVertex;
    using ConstVertexIterator = const VertexType*;
    using IndexType = uint16_t;
    static constexpr size_t faceVertexCount = 3;
    
    struct Face {
        const VertexType& v0;
        const VertexType& v1;
        const VertexType& v2;
    };
    
    class ConstFaceIterator {
    public:
        
        const Face operator*();
        ConstFaceIterator& operator++();
        bool operator!=(const ConstFaceIterator& rhs) const;
        
        const VertexType* _vertices;
        const IndexType* _indicies;
        
    private:
        ConstFaceIterator(const VertexType* vertices, const IndexType* indicies);
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
    size_t vertexCount() const;
    
    const ghi::Buffer* indexBuffer() const;
    size_t indexCount() const;
    size_t faceCount() const;
    
    const SPTAABB& boundingBox() const;
    
private:
    std::unique_ptr<ghi::Buffer> _vertexBuffer;
    std::unique_ptr<ghi::Buffer> _indexBuffer;
    SPTAABB _boundingBox;
};

inline Mesh::ConstFaceIterator::ConstFaceIterator(const VertexType* vertices, const IndexType* indicies)
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
    return Mesh::ConstFaceIterator {static_cast<VertexType*>(_vertexBuffer->data()), static_cast<IndexType*>(_indexBuffer->data())};
}

inline Mesh::ConstFaceIterator Mesh::cFaceEnd() const {
    return Mesh::ConstFaceIterator {static_cast<VertexType*>(_vertexBuffer->data()), static_cast<IndexType*>(_indexBuffer->data()) + indexCount()};
}

inline const ghi::Buffer* Mesh::vertexBuffer() const {
    return _vertexBuffer.get();
}

inline size_t Mesh::vertexCount() const {
    return _vertexBuffer->size() / sizeof(VertexType);
}

inline const ghi::Buffer* Mesh::indexBuffer() const {
    return _indexBuffer.get();
}

inline size_t Mesh::indexCount() const {
    return _indexBuffer->size() / sizeof(Mesh::IndexType);
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
