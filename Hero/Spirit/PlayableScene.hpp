//
//  PlayableScene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#pragma once

#include "Base.hpp"
#include "Renderer.hpp"

#include <entt/entt.hpp>

namespace spt {

struct Scene;

struct PlayableScene {
  
    void setupFromScene(const Scene* scene, SPTEntity viewCameraEntity);
    
    void render(void* renderingContext);
    
    SPTEntity viewCameraEntity;
    
    Registry registry;
    Renderer renderer {registry};
};

}
