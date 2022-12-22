//
//  Action.h
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.22.
//

#pragma once

#include "Base.h"
#include "Position.h"
#include "Easing.h"


SPT_EXTERN_C_BEGIN

// MARK: Position
void SPTPositionActionMake(SPTObject object, SPTPosition position, double duration, SPTEasingType easing);

bool SPTPositionActionExists(SPTObject object);

void SPTPositionActionDestroy(SPTObject object);


// MARK: Orientation
void SPTOrientationActionMakeLookAtTarget(SPTObject object, simd_float3 target, double duration, SPTEasingType easing);

bool SPTOrientationActionExists(SPTObject object);

void SPTOrientationActionDestroy(SPTObject object);

SPT_EXTERN_C_END
