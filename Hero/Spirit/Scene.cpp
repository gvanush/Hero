//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Scene.hpp"
#include "Transformation.hpp"
#include "Generator.hpp"

namespace spt {

Scene::Scene()
: componentUpdateNotifiers {registry, registry, registry} {
    registry.on_destroy<Generator>().connect<&Generator::onDestroy>();
}

Scene::~Scene() {
    registry.on_destroy<Generator>().disconnect<&Generator::onDestroy>();
}

void Scene::render(void* renderingContext) {
    meshRenderer.render(renderingContext);
    
    std::apply([] (auto& ...notifier) {
        (..., notifier.notify());
    }, componentUpdateNotifiers);
}

}
