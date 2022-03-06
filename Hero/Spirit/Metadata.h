//
//  Metadata.h
//  Hero
//
//  Created by Vanush Grigoryan on 06.03.22.
//

#pragma once

#include "Base.h"

SPT_EXTERN_C_BEGIN

typedef struct {
    int32_t tag;
} SPTMetadata;

void SPTMetadataMake(SPTObject object, SPTMetadata metadata);

SPTMetadata SPTMetadataGet(SPTObject object);

SPT_EXTERN_C_END
