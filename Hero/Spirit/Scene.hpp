//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "Renderer.hpp"
#include "Transformation.hpp"

#include <entt/entt.hpp>
#include <tuple>
#include <vector>

namespace spt {

class Scene {
public:
    Scene();
    ~Scene();
    
    void update();
    
    void onPostRender();
    
    static Registry& getRegistry(SPTHandle sceneHandle) {
        return static_cast<spt::Scene*>(sceneHandle)->registry;
    }
    
    static Registry& getRegistry(SPTObject object) {
        return getRegistry(object.sceneHandle);
    }
    
    static void destroyObject(SPTObject object);
    
    static void destroyObjectDeferred(SPTObject object);
    
    Registry registry;
    
private:
    Transformation::GroupType _transformationGroup;
    std::vector<SPTEntity> _entitiesScheduledToDestroy;
    std::vector<SPTEntity> _entitiesToDestroy;
};

}
