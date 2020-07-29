//
//  World.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#pragma once

#include <vector>
#include <simd/simd.h>

namespace hero {

class Layer {
public:
    // setPosition()
    void setBgrColor(const simd::float3& color);
//    void setTexture(MTLTexture)
    
};

class World {
public:
    
    void addLayer(Layer* layer);
    
    void setBgrColor(const simd::float3& color);
    
    void render();
    
private:
    
    std::vector<Layer*> _layers;
    
};

}
