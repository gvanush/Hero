//
//  Common.h
//  Hero
//
//  Created by Vanush Grigoryan on 12.11.21.
//

#pragma once

#include <stdint.h>

typedef enum : uint32_t {
    _dummy
} spt_entity_id;

typedef void* spt_scene_handle;

typedef struct {
    spt_entity_id id;
    spt_scene_handle const sceneHandle;
} spt_entity;
