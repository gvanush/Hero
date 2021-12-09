//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Scene.hpp"

namespace spt {

void Scene::render(void* renderingContext) {
    meshRenderer.render(renderingContext);
    polylineRenderer.render(renderingContext);
}

}
