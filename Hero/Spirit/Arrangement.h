//
//  Arrangement.h
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

#pragma once

#include "Base.h"
#include "Geometry.h"

typedef enum {
    SPTArrangementVariantTagPoint,
    SPTArrangementVariantTagLinear,
    SPTArrangementVariantTagPlanar,
    SPTArrangementVariantTagSpatial,
} __attribute__((enum_extensibility(closed))) SPTArrangementVariantTag;

typedef struct {
    bool __dummy;
} SPTPointArrangement;


typedef struct {
    SPTAxis axis;
} SPTLinearArrangement;


typedef struct {
    SPTPlain plain;
} SPTPlanarArrangement;


typedef struct {
    bool __dummy;
} SPTSpatialArrangement;


typedef struct {
    SPTArrangementVariantTag variantTag;
    union {
        SPTPointArrangement point;
        SPTLinearArrangement linear;
        SPTPlanarArrangement planar;
        SPTSpatialArrangement spatial;
    };
} SPTArrangement;


SPT_EXTERN_C_BEGIN

bool SPTPointArrangementEqual(SPTPointArrangement lhs, SPTPointArrangement rhs);

bool SPTLinearArrangementEqual(SPTLinearArrangement lhs, SPTLinearArrangement rhs);

bool SPTPlanarArrangementEqual(SPTPlanarArrangement lhs, SPTPlanarArrangement rhs);

bool SPTArrangementEqual(SPTArrangement lhs, SPTArrangement rhs);

bool SPTSpatialArrangementEqual(SPTSpatialArrangement lhs, SPTSpatialArrangement rhs);

SPT_EXTERN_C_END
