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

-(spt_entity) makeEntity {
    return _scene.makeEntity();
}

-(spt_scene_handle) cpp {
    return &_scene;
}

+(void) destroyEntity: (spt_entity) entity {
    spt::Scene::destroyEntity(entity);
}

@end
