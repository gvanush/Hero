//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Scene.hpp"
#include "Scene.h"

#include <vector>

namespace spt {

Scene::Scene()
: _transformationGroup {registry.group<DirtyTransformationFlag, Transformation>()} {
    registry.on_destroy<Transformation>().connect<&Transformation::onDestroy>();
}

Scene::~Scene() {
    registry.on_destroy<Transformation>().disconnect<&Transformation::onDestroy>();
}

void Scene::update() {
    Transformation::updateWithoutAnimators(registry, _transformationGroup);
}

}

SPTHandle SPTSceneMake() {
    return new spt::Scene();
}

void SPTSceneDestroy(SPTHandle handle) {
    delete static_cast<spt::Scene*>(handle);
}

SPTObject SPTSceneMakeObject(SPTHandle sceneHandle) {
    auto& registry = spt::Scene::getRegistry(sceneHandle);
    const auto entity = registry.create();
    registry.emplace<spt::Transformation>(entity);
    return SPTObject { entity, sceneHandle };
}

void SPTSceneDestroyObject(SPTObject object) {
    assert(!SPTIsNull(object));
    // Removing all 'Transformation' component children as well.
    // Prefering iterative over recursive algorithm to avoid stack overflow.
    // Possibly this can be optimized by vector reserve
    auto& registry = spt::Scene::getRegistry(object);
    
    std::vector<SPTEntity> entities {1, object.entity};
    for (std::size_t i = 0; i < entities.size(); ++i) {
        const auto entity = entities[i];
        spt::Transformation::forEachChild(registry, entity, [&entities] (auto childEntity, const auto&) {
            entities.push_back(childEntity);
        });
    }
    
    // Destroy children first then parents since children need to remove themselves from their parents
    for(auto it = entities.crbegin(); it != entities.crend(); ++it) {
        registry.destroy(*it);
    }
}
