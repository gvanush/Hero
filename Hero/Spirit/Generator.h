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

void SPTGeneratorMake(SPTObject object, SPTGenerator generator);

void SPTGeneratorUpdate(SPTObject object, SPTGenerator updated);

void SPTGeneratorDestroy(SPTObject object);

SPTGenerator SPTGeneratorGet(SPTObject object);

const SPTGenerator* _Nullable SPTGeneratorTryGet(SPTObject object);

bool SPTGeneratorExists(SPTObject object);

typedef void (* _Nonnull SPTGeneratorWillChangeObserver) (SPTGenerator, SPTComponentObserverUserInfo);
SPTComponentObserverToken SPTGeneratorAddWillChangeObserver(SPTObject object, SPTGeneratorWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTGeneratorRemoveWillChangeObserver(SPTObject object, SPTComponentObserverToken token);

typedef void (* _Nonnull SPTGeneratorWillEmergeObserver) (SPTGenerator, SPTComponentObserverUserInfo);
SPTComponentObserverToken SPTGeneratorAddWillEmergeObserver(SPTObject object, SPTGeneratorWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTGeneratorRemoveWillEmergeObserver(SPTObject object, SPTComponentObserverToken token);

typedef void (* _Nonnull SPTGeneratorWillPerishObserver) (SPTComponentObserverUserInfo);
SPTComponentObserverToken SPTGeneratorAddWillPerishObserver(SPTObject object, SPTGeneratorWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTGeneratorRemoveWillPerishObserver(SPTObject object, SPTComponentObserverToken token);

SPT_EXTERN_C_END
