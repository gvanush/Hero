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

// Destroys object 2 frames after the request.
// These are enough run loop cycles for SwiftUI to process
// object dependent views lifecycle calls (onChange, onDisappear)
// which need object to be alive
// NOTE: Possibly actual destroy could be done 1 frame after the request
// however the destruction must be plugged in run loop observer
// that happens after SwiftUI view lifecycle calls. Needs further investigation. 
void SPTSceneDestroyObjectDeferred(SPTObject object);

SPT_EXTERN_C_END
