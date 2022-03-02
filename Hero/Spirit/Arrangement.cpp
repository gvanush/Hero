//
//  Arrangement.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

#include "Arrangement.h"

bool SPTArrangementEqual(SPTArrangement lhs, SPTArrangement rhs) {
    if(lhs.variantTag != rhs.variantTag) {
        return false;
    }
    
    switch (lhs.variantTag) {
        case SPTArrangementVariantTagPoint:
            return SPTPointArrangementEqual(lhs.point, rhs.point);
        case SPTArrangementVariantTagLinear:
            return SPTLinearArrangementEqual(lhs.linear, rhs.linear);
        case SPTArrangementVariantTagPlanar:
            return SPTPlanarArrangementEqual(lhs.planar, rhs.planar);
        case SPTArrangementVariantTagSpatial:
            return SPTSpatialArrangementEqual(lhs.spatial, rhs.spatial);
    }
}


bool SPTPointArrangementEqual(SPTPointArrangement lhs, SPTPointArrangement rhs) {
    return true;
}


bool SPTLinearArrangementEqual(SPTLinearArrangement lhs, SPTLinearArrangement rhs) {
    return lhs.axis == rhs.axis;
}


bool SPTPlanarArrangementEqual(SPTPlanarArrangement lhs, SPTPlanarArrangement rhs) {
    return lhs.plain == rhs.plain;
}


bool SPTSpatialArrangementEqual(SPTSpatialArrangement lhs, SPTSpatialArrangement rhs) {
    return true;
}
