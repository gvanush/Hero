//
//  Renderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/26/20.
//

#pragma once

#include "Renderer_Common.h"

#include <cstdint>
#include <climits>
#include <cstddef>
#include <array>

namespace hero {

class Scene;
class RenderingContext;

class Renderer {
public:
    
    ~Renderer();
    
    void render(Scene& scene, RenderingContext& renderingContext);
    
    inline RendererFlag flag() const;
    
    static constexpr std::size_t kLimit = sizeof(RendererFlag) * CHAR_BIT;
  
    static void setup();
    
    // Retruns null when overall number of renderers reaches the limit
    static Renderer* make();
    
    static Renderer* get(RendererFlag flag);
    
    static const std::array<Renderer*, kLimit>& allRenderers();
    
private:
    
    Renderer(RendererFlag flag);
    
    static std::array<Renderer*, kLimit> _allRenderers;
    
    RendererFlag _flag;
    
};

RendererFlag Renderer::flag() const {
    return _flag;
}

}
