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
    
    void cloneEntities(const Scene& scene, const SPTPlayableSceneDescriptor& descriptor);
    void prepareTransformationAnimations(const Scene& scene, const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex);
    void prepareMeshLookAnimations(const Scene& scene, const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex);
    
    template <SPTAnimatableObjectProperty P>
    void prepareRGBChannelAnimation(const Scene& scene,  const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex);
    
    template <SPTAnimatableObjectProperty P>
    void forEachHSBChannelBinding(const Scene& scene,  const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex, const std::function<void (SPTEntity, const AnimatorBindingItemBase&)>& action);
    
    std::vector<SPTAnimatorId> _animatorIds;
    std::vector<float> _animatorValues;
    Transformation::AnimatorsGroupType _transformationGroup;
    
};

}
