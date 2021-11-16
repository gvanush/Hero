//
//  Common.h
//  Hero
//
//  Created by Vanush Grigoryan on 12.11.21.
//

#pragma once

#include <stdint.h>
#include <stdbool.h>

typedef enum : uint32_t {
    _dummy
} spt_entity_id;

typedef void* spt_scene_handle;

typedef struct {
    spt_entity_id id;
    spt_scene_handle sceneHandle;
} spt_entity;

extern const spt_entity spt_k_null_entity;


#ifdef __cplusplus
# define SPT_EXTERN_C_BEGIN extern "C" {
# define SPT_EXTERN_C_END   }
#else
# define SPT_EXTERN_C_BEGIN
# define SPT_EXTERN_C_END
#endif

SPT_EXTERN_C_BEGIN

bool spt_is_valid(spt_entity entity);

SPT_EXTERN_C_END
