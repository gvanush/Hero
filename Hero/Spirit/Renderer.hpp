//
//  Renderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "ShaderTypes.h"
#include "Base.hpp"

namespace spt {

class Renderer {
public:
    
    void render(const Registry& registry, void* renderingContext);

    static void init();
    
private:
    Uniforms _uniforms;
};

}
