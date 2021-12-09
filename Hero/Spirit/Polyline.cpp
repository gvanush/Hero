//
//  Polyline.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.21.
//

#include "Polyline.hpp"

namespace spt {

Polyline::Polyline(std::unique_ptr<ghi::Buffer> vertexBuffer, std::unique_ptr<ghi::Buffer> indexBuffer, const SPTAABB& boundingBox)
: _vertexBuffer{std::move(vertexBuffer)}
, _indexBuffer{std::move(indexBuffer)}
, _boundingBox{boundingBox} {
    
}

}
