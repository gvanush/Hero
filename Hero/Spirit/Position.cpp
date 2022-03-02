//
//  Position.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Position.h"
#include "Position.hpp"
#include "Scene.hpp"
#include "ComponentListenerUtil.hpp"
#include "ComponentUpdateNotifier.hpp"

bool SPTSphericalPositionEqual(SPTSphericalPosition lhs, SPTSphericalPosition rhs) {
    return simd_equal(lhs.center, rhs.center) &&
    lhs.radius == rhs.radius &&
    lhs.longitude == rhs.longitude &&
    lhs.latitude == rhs.latitude;
}

bool SPTPositionEqual(SPTPosition lhs, SPTPosition rhs) {
    if(lhs.variantTag != rhs.variantTag) {
        return false;
    }
    
    switch (lhs.variantTag) {
        case SPTPositionVariantTagXYZ:
            return simd_equal(lhs.xyz, rhs.xyz);
        case SPTPositionVariantTagSpherical:
            return SPTSphericalPositionEqual(lhs.spherical, rhs.spherical);
    }
}

void SPTPositionMake(SPTObject object, SPTPosition position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTPosition>(object.entity, position);
}

void SPTPositionMakeXYZ(SPTObject object, simd_float3 xyz) {
    SPTPositionMake(object, {SPTPositionVariantTagXYZ, {.xyz = xyz}});
}

void SPTPositionMakeSpherical(SPTObject object, SPTSphericalPosition spherical) {
    SPTPositionMake(object, {SPTPositionVariantTagSpherical, {.spherical = spherical}});
}

void SPTPositionUpdate(SPTObject object, SPTPosition newPosition) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTPosition>::onWillChange(registry, object.entity, newPosition);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTPosition>(object.entity) = newPosition;
}

SPTPosition SPTPositionGet(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTPosition>(object.entity);
}

simd_float3 SPTPositionGetXYZ(SPTObject object) {
    return spt::Position::getXYZ(static_cast<spt::Scene*>(object.sceneHandle)->registry, object.entity);
}

void SPTPositionAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTPositionWillChangeCallback callback) {
    spt::addComponentWillChangeListener<SPTPosition>(object, listener, callback);
}

void SPTPositionRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTPositionWillChangeCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTPosition>(object, listener, callback);
}

void SPTPositionRemoveWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTPosition>(object, listener);
}

simd_float3 SPTPositionConvertSphericalToXYZ(SPTSphericalPosition sphericalPosition) {
    float lngSin = sinf(sphericalPosition.longitude);
    float lngCos = cosf(sphericalPosition.longitude);
    float latSin = sinf(sphericalPosition.latitude);
    float latCos = cosf(sphericalPosition.latitude);
    return sphericalPosition.center + sphericalPosition.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);
}

namespace spt {

namespace Position {

simd_float3 getXYZ(const spt::Registry& registry, SPTEntity entity) {
    if(const auto position = registry.try_get<SPTPosition>(entity)) {
        switch (position->variantTag) {
            case SPTPositionVariantTagXYZ: {
                return position->xyz;
            }
            case SPTPositionVariantTagSpherical: {
                return SPTPositionConvertSphericalToXYZ(position->spherical);
            }
        }
    }
    return {0.f, 0.f, 0.f};
}

}

}
