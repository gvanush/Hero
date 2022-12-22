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

typedef struct {
    SPTEntity viewCameraEntity;
    const SPTAnimatorId* _Nullable animatorIds;
    uint32_t animatorsSize;
} SPTPlayableSceneDescriptor;

SPTHandle SPTPlayableSceneMake(SPTHandle sceneHandle, SPTPlayableSceneDescriptor descriptor);

void SPTPlayableSceneDestroy(SPTHandle sceneHandle);

SPTPlayableSceneParams SPTPlayableSceneGetParams(SPTHandle sceneHandle);

SPT_EXTERN_C_END
