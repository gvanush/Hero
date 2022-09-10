//
//  PlayableScene.h
//  Hero
//
//  Created by Vanush Grigoryan on 10.09.22.
//

#pragma once

#include "Base.h"


SPT_EXTERN_C_BEGIN

typedef struct {
    SPTEntity viewCameraEntity;
} SPTPlayableSceneParams;

SPTHandle SPTPlayableSceneMake(SPTHandle sceneHandle, SPTEntity viewCameraEntity);

void SPTPlayableSceneDestroy(SPTHandle sceneHandle);

SPTPlayableSceneParams SPTPlayableSceneGetParams(SPTHandle sceneHandle);

SPT_EXTERN_C_END
