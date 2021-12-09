//
//  Polyline.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.21.
//

#pragma once

#include "ShaderTypes.h"
#include "Geometry.h"
#include "GHI/Buffer.hpp"

#include <memory>

namespace spt {

class Polyline {
public:
    
    using Vertex = PolylineVertex;
    
    Polyline(std::unique_ptr<ghi::Buffer> vertexBuffer, std::unique_ptr<ghi::Buffer> indexBuffer, const SPTAABB& boundingBox);
    Polyline(Polyline&&) = default;
    Polyline& operator=(Polyline&&) = default;
    Polyline(const Polyline&) = delete;
    Polyline& operator=(const Polyline&) = delete;
    
    size_t segmentCount() const;
    
    const ghi::Buffer* vertexBuffer() const;
    ghi::UInt vertexCount() const;
    
    const ghi::Buffer* indexBuffer() const;
    ghi::UInt indexCount() const;
    
private:
    std::unique_ptr<ghi::Buffer> _vertexBuffer;
    std::unique_ptr<ghi::Buffer> _indexBuffer;
    SPTAABB _boundingBox;
};

inline size_t Polyline::segmentCount() const {
    return indexCount() / 6;
}

inline const ghi::Buffer* Polyline::vertexBuffer() const {
    return _vertexBuffer.get();
}

inline ghi::UInt Polyline::vertexCount() const {
    return _vertexBuffer->size() / sizeof(Vertex);
}

inline const ghi::Buffer* Polyline::indexBuffer() const {
    return _indexBuffer.get();
}

inline ghi::UInt Polyline::indexCount() const {
    return _indexBuffer->size() / sizeof(Vertex::Index);
}

}

