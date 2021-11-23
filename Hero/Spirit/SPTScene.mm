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

-(SPTObject) makeObject {
    return _scene.makeObject();
}

-(SPTSceneHandle) cpp {
    return &_scene;
}

+(void) destroyObject: (SPTObject) entity {
    spt::Scene::destroyObject(entity);
}

@end
