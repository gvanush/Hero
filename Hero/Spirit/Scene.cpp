//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Scene.hpp"
#include "Generator.hpp"

#include <vector>

namespace spt {

Scene::Scene()
: transformationGroup {registry.group<DirtyTransformationFlag, Transformation>()} {
    registry.on_destroy<Generator>().connect<&Generator::onDestroy>();
    registry.on_destroy<Transformation>().connect<&Transformation::onDestroy>();
}

Scene::~Scene() {
    registry.on_destroy<Generator>().disconnect<&Generator::onDestroy>();
    registry.on_destroy<Transformation>().disconnect<&Transformation::onDestroy>();
}

SPTObject Scene::makeObject() {
    const auto entity = registry.create();
    registry.emplace<Transformation>(entity);
    return SPTObject { entity, this };
}

void Scene::destroyObject(SPTObject object) {
    assert(!SPTIsNull(object));
    // Removing all 'Transformation' component children as well.
    // Prefering iterative over recursive algorithm to avoid stack overflow.
    // Possibly this can be optimized by vector reserve
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    
    std::vector<SPTEntity> entities {1, object.entity};
    for (std::size_t i = 0; i < entities.size(); ++i) {
        const auto entity = entities[i];
        Transformation::forEachChild(registry, entity, [&entities] (auto childEntity, const auto&) {
            entities.push_back(childEntity);
        });
    }
    
    // Destroy children first then parents since children need to remove themselves from their parents
    for(auto it = entities.crbegin(); it != entities.crend(); ++it) {
        registry.destroy(*it);
    }
}

void Scene::onPrerender() {
    Transformation::update(registry, transformationGroup);
}

void Scene::render(void* renderingContext) {
    renderer.render(renderingContext);
}

}
