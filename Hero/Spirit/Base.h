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

SPT_EXTERN_C_BEGIN

typedef enum : uint32_t {
    _dummy
} SPTEntity;

typedef void* SPTSceneHandle;

typedef struct {
    SPTEntity entity;
    SPTSceneHandle sceneHandle;
} SPTObject;

extern const SPTObject kSPTNullObject;

bool SPTIsValid(SPTObject entity);

SPT_EXTERN_C_END
