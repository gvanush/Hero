//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Scene.hpp"
#include "Transformation.hpp"

namespace spt {

Scene::Scene()
: componentUpdateNotifiers {registry, registry, registry} {
}

void Scene::render(void* renderingContext) {
    meshRenderer.render(renderingContext);
    
    std::apply([] (auto& ...notifier) {
        (..., notifier.notify());
    }, componentUpdateNotifiers);
}

}
