//
//  OutlineRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.21.
//

#pragma once

#include "ShaderTypes.h"
#include "Base.hpp"

namespace spt {

class OutlineRenderer {
public:
    
    OutlineRenderer(Registry& registry);
    
    void render(void* renderingContext);

    static void init();
    
private:
    Registry& _registry;
    Uniforms _uniforms;
};

}
