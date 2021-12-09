//
//  PolylineRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 07.12.21.
//

#pragma once

#include "ShaderTypes.h"
#include "Base.hpp"

namespace spt {

class PolylineRenderer {
public:
    
    PolylineRenderer(Registry& registry);
    
    void render(void* renderingContext);

    static void init();
    
private:
    Registry& _registry;
    Uniforms _uniforms;
};

}
