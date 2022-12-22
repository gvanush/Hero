//
//  Action.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.22.
//

#include "Action.h"
#include "Scene.hpp"
#include "Orientation.h"

namespace spt {

template <typename CT>
struct Action {
    CT startValue;
    CT deltaValue;
    double duration;
    double startTime;
    SPTEasingType easing;
};

void updateActions(Registry& registry, double time) {
    
    registry.view<Action<SPTPosition>>().each([&registry, time] (SPTEntity entity, const Action<SPTPosition>& action) {
        
        spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, entity);
        
        const auto passed = time - action.startTime;
        if (passed >= action.duration) {
            registry.get<SPTPosition>(entity) = SPTPositionAdd(action.startValue, action.deltaValue);
            registry.erase<Action<SPTPosition>>(entity);
        } else {
            const auto tNorm = SPTEasingEvaluate(action.easing, passed / action.duration);
            registry.get<SPTPosition>(entity) = SPTPositionAdd(action.startValue, SPTPositionMultiplyScalar(action.deltaValue, tNorm));
        }
        
    });
    
    registry.view<Action<SPTOrientation>>().each([&registry, time] (SPTEntity entity, const Action<SPTOrientation>& action) {
        
        spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, entity);
        
        auto& orientation = registry.get<SPTOrientation>(entity);
        assert(orientation.type == SPTOrientationTypeLookAtPoint);
        
        const auto passed = time - action.startTime;
        if (passed >= action.duration) {
            orientation.lookAtPoint.target = action.startValue.lookAtPoint.target + action.deltaValue.lookAtPoint.target;
            registry.erase<Action<SPTOrientation>>(entity);
        } else {
            const auto tNorm = SPTEasingEvaluate(action.easing, passed / action.duration);
            orientation.lookAtPoint.target = action.startValue.lookAtPoint.target + tNorm * action.deltaValue.lookAtPoint.target;
        }
        
    });
    
}

}

// MARK: Position
void SPTPositionActionMake(SPTObject object, SPTPosition position, double duration, SPTEasingType easing) {
    
    auto& scene = *static_cast<spt::Scene*>(object.sceneHandle);
    const auto& startPosition = scene.registry.get<SPTPosition>(object.entity);
    assert(startPosition.coordinateSystem == position.coordinateSystem);
    
    scene.registry.emplace_or_replace<spt::Action<SPTPosition>>(object.entity, spt::Action<SPTPosition>{startPosition, SPTPositionSubtract(position, startPosition), duration, scene.time(), easing});
}

bool SPTPositionActionExists(SPTObject object) {
    return spt::Scene::getRegistry(object).all_of<spt::Action<SPTPosition>>(object.entity);
}

void SPTPositionActionDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<spt::Action<SPTPosition>>(object.entity);
}

// MARK: Orientation
void SPTOrientationActionMakeLookAtTarget(SPTObject object, simd_float3 target, double duration, SPTEasingType easing) {
    auto& scene = *static_cast<spt::Scene*>(object.sceneHandle);
    const auto& startOrientation = scene.registry.get<SPTOrientation>(object.entity);
    assert(startOrientation.type == SPTOrientationTypeLookAtPoint);
    
    auto delta = startOrientation;
    delta.lookAtPoint.target = target - startOrientation.lookAtPoint.target;
    
    scene.registry.emplace_or_replace<spt::Action<SPTOrientation>>(object.entity, spt::Action<SPTOrientation>{startOrientation, delta, duration, scene.time(), easing});
}

bool SPTOrientationActionExists(SPTObject object) {
    return spt::Scene::getRegistry(object).all_of<spt::Action<SPTOrientation>>(object.entity);
}

void SPTOrientationActionDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<spt::Action<SPTOrientation>>(object.entity);
}
