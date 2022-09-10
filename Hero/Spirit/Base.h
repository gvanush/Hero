//
//  Common.h
//  Hero
//
//  Created by Vanush Grigoryan on 12.11.21.
//

#pragma once

#ifdef __cplusplus
# define SPT_EXTERN_C_BEGIN extern "C" {
# define SPT_EXTERN_C_END   }
#else
# define SPT_EXTERN_C_BEGIN
# define SPT_EXTERN_C_END
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

SPT_EXTERN_C_BEGIN

typedef enum : uint32_t {
    _dummy
} SPTEntity;

typedef void* _Nonnull SPTHandle;

typedef struct {
    SPTEntity entity;
    SPTHandle sceneHandle;
} SPTObject;

extern const SPTEntity kSPTNullEntity;
extern const SPTObject kSPTNullObject;

bool SPTIsNull(SPTObject object);

bool SPTIsValid(SPTObject object);

bool SPTObjectEqual(SPTObject object1, SPTObject object2);

typedef void* _Nonnull SPTListener;

typedef void (* _Nonnull SPTCountWillChangeCallback) (SPTListener, size_t);

typedef size_t SPTObserverToken;
typedef void* _Nullable SPTComponentObserverUserInfo;

typedef uint32_t SPTLookCategories;
extern const SPTLookCategories kSPTLookCategoriesAll;

SPT_EXTERN_C_END
