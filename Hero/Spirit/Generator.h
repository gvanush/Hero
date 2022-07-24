//
//  Generator.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Mesh.h"
#include "Arrangement.h"

typedef uint16_t SPTGeneratorQuantityType;

typedef struct {
    SPTArrangement arrangement;
    SPTMeshId sourceMeshId;
    SPTGeneratorQuantityType quantity;
} SPTGenerator;

const SPTGeneratorQuantityType kSPTGeneratorMinQuantity = 1;
const SPTGeneratorQuantityType kSPTGeneratorMaxQuantity = 1000;

SPT_EXTERN_C_BEGIN

bool SPTGeneratorEqual(SPTGenerator lhs, SPTGenerator rhs);

SPTGenerator SPTGeneratorMake(SPTObject object, SPTMeshId sourceMeshId, SPTGeneratorQuantityType quantity);

void SPTGeneratorUpdate(SPTObject object, SPTGenerator updated);

SPTGenerator SPTGeneratorGet(SPTObject object);

typedef void (* _Nonnull SPTGeneratorWillChangeCallback) (SPTListener, SPTGenerator);
void SPTGeneratorAddWillChangeListener(SPTObject object, SPTListener listener, SPTGeneratorWillChangeCallback callback);
void SPTGeneratorRemoveWillChangeListenerCallback(SPTObject object, SPTListener listener, SPTGeneratorWillChangeCallback callback);
void SPTGeneratorRemoveWillChangeListener(SPTObject object, SPTListener listener);

SPT_EXTERN_C_END
