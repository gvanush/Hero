//
//  Generator.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Mesh.h"

// MARK: Arrangement
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

// MARK: Generator
typedef uint16_t SPTGeneratorQuantityType;

typedef struct {
    SPTArrangement arrangement;
    SPTMeshId sourceMeshId;
    SPTGeneratorQuantityType quantity;
} SPTGenerator;

const SPTGeneratorQuantityType kSPTGeneratorMinQuantity = 1;
const SPTGeneratorQuantityType kSPTGeneratorMaxQuantity = 1000;

SPT_EXTERN_C_BEGIN

SPTGenerator SPTMakeGenerator(SPTObject object, SPTMeshId sourceMeshId, SPTGeneratorQuantityType quantity);

SPTGenerator SPTGetGenerator(SPTObject object);

void SPTUpdateGenerator(SPTObject object, SPTGenerator updated);

void SPTAddGeneratorWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveGeneratorWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveGeneratorWillChangeListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
