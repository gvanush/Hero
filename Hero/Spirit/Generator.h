//
//  Generator.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Mesh.h"

typedef struct {
    SPTMeshId sourceMeshId;
    uint16_t quantity;
} SPTGeneratorBase;

SPT_EXTERN_C_BEGIN

SPTGeneratorBase SPTMakeGenerator(SPTObject object, SPTMeshId sourceMeshId, uint16_t quantity);

SPTGeneratorBase SPTGetGenerator(SPTObject object);

void SPTUpdateGeneratorSourceMesh(SPTObject object, SPTMeshId sourceMeshId);

void SPTAddGeneratorListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveGeneratorListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveGeneratorListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
