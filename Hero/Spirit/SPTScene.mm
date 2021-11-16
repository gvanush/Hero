//
//  SPTScene.m
//  Hero
//
//  Created by Vanush Grigoryan on 11.11.21.
//

#import "SPTScene.h"

#include "Scene.hpp"

#include <entt/entt.hpp>

@interface SPTScene () {
    spt::Scene _scene;
}

@end

@implementation SPTScene

-(SPTObject) makeEntity {
    return _scene.makeEntity();
}

-(SPTSceneHandle) cpp {
    return &_scene;
}

+(void) destroyEntity: (SPTObject) entity {
    spt::Scene::destroyEntity(entity);
}

@end
