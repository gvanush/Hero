//
//  MeshRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "ShaderTypes.h"

#include <simd/simd.h>

namespace spt {

class MeshRenderer {
public:
    
    void render(void* renderingContext);

    static void init();
    
private:
    Uniforms _uniforms;
};

}
