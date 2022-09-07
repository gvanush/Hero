//
//  SPTPlayableScene.m
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#import "SPTPlayableScene.h"
#import "SPTScene.h"

#include "PlayableScene.hpp"

@interface SPTPlayableScene () {
    spt::PlayableScene _scene;
}

@end


@implementation SPTPlayableScene

-(SPTSceneHandle) cpp {
    return &_scene;
}

+(SPTPlayableScene*) makeFromScene: (SPTScene*) scene viewCameraEntity: (SPTEntity) viewCameraEntity {
    SPTPlayableScene* playableScene = [[SPTPlayableScene alloc] init];
    static_cast<spt::PlayableScene*>(playableScene.cpp)->setupFromScene(static_cast<spt::Scene*>(scene.cpp), viewCameraEntity);
    return playableScene;
}

-(SPTEntity) viewCameraEntity {
    return _scene.viewCameraEntity;
}

@end
