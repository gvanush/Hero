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
#include "Animator.h"

#include <entt/entt.hpp>

namespace spt {

struct AnimatorItem {
    SPTAnimator animator;
    float value;
};


struct PlayableScene {
    
    void render(void* renderingContext);
    
    void evaluateAnimators(const SPTAnimatorEvaluationContext& context);
    
    std::vector<AnimatorItem> animatorItems;
    SPTPlayableSceneParams params;
    
    Registry registry;
    Renderer renderer {registry};
};

}
