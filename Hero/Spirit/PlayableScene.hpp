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
#include "Transformation.hpp"

#include <entt/entt.hpp>

namespace spt {

class Scene;

class PlayableScene {
public:
    PlayableScene(const Scene& scene, const SPTPlayableSceneDescriptor& descriptor);
    
    void evaluateAnimators(const SPTAnimatorEvaluationContext& context);
    void update();
    
    SPTPlayableSceneParams params;
    Registry registry;
    
private:
    
    std::vector<SPTAnimator> _animators;
    std::vector<float> _animatorValues;
    Transformation::AnimatorsGroupType _transformationGroup;
    
};

}
