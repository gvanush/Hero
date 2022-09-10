//
//  Scene.h
//  Hero
//
//  Created by Vanush Grigoryan on 09.09.22.
//

#include "Base.h"


SPT_EXTERN_C_BEGIN

SPTHandle SPTSceneMake();

void SPTSceneDestroy(SPTHandle handle);

SPTObject SPTSceneMakeObject(SPTHandle sceneHandle);

void SPTSceneDestroyObject(SPTObject object);

SPT_EXTERN_C_END
