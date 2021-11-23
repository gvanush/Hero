//
//  MeshRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "ShaderTypes.h"
#include "Base.hpp"

#include <simd/simd.h>

namespace spt {

class MeshRenderer {
public:
    
    MeshRenderer(Registry& registry);
    
    void render(void* renderingContext);

    static void init();
    
private:
    Registry& _registry;
    Uniforms _uniforms;
};

}
