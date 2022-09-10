//
//  PlayableScene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#pragma once

#include "Base.hpp"
#include "PlayableScene.h"
#include "Renderer.hpp"

#include <entt/entt.hpp>

namespace spt {

struct Scene;

struct PlayableScene {
    
    void render(void* renderingContext);
    
    SPTPlayableSceneParams params;
    
    Registry registry;
    Renderer renderer {registry};
};

}
