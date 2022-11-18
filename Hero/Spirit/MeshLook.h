//
//  MeshLook.h
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#pragma once

#include "Base.h"
#include "Mesh.h"
#include "Materials.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTMeshShadingTypePlainColor,
    SPTMeshShadingTypeBlinnPhong
} __attribute__((enum_extensibility(closed))) SPTMeshShadingType;

typedef struct {
    SPTMeshShadingType type;
    union {
        SPTPlainColorMaterial plainColor;
        SPTPhongMaterial blinnPhong;
    };
} SPTMeshShading;

bool SPTMeshShadingValidate(SPTMeshShading shading);

bool SPTMeshShadingEqual(SPTMeshShading lhs, SPTMeshShading rhs);

typedef struct {
    SPTMeshShading shading;
    SPTMeshId meshId;
    SPTLookCategories categories;
} SPTMeshLook;

bool SPTMeshLookEqual(SPTMeshLook lhs, SPTMeshLook rhs);

void SPTMeshLookMake(SPTObject object, SPTMeshLook meshLook);

void SPTMeshLookUpdate(SPTObject object, SPTMeshLook updated);

void SPTMeshLookDestroy(SPTObject object);

SPTMeshLook SPTMeshLookGet(SPTObject object);

const SPTMeshLook* _Nullable SPTMeshLookTryGet(SPTObject object);

bool SPTMeshLookExists(SPTObject object);

typedef void (* _Nonnull SPTMeshLookWillChangeObserver) (SPTMeshLook, SPTObserverUserInfo);
SPTObserverToken SPTMeshLookAddWillChangeObserver(SPTObject object, SPTMeshLookWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTMeshLookRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTMeshLookDidEmergeObserver) (SPTMeshLook, SPTObserverUserInfo);
SPTObserverToken SPTMeshLookAddDidEmergeObserver(SPTObject object, SPTMeshLookDidEmergeObserver observer, SPTObserverUserInfo userInfo);
void SPTMeshLookRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTMeshLookWillPerishObserver) (SPTObserverUserInfo);
SPTObserverToken SPTMeshLookAddWillPerishObserver(SPTObject object, SPTMeshLookWillPerishObserver observer, SPTObserverUserInfo userInfo);
void SPTMeshLookRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
