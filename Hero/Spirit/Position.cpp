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

void SPTMakePosition(SPTObject object, SPTPosition position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTPosition>(object.entity, position);
}

void SPTUpdatePosition(SPTObject object, SPTPosition position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTPosition>::onWillChange(registry, object.entity);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTPosition>(object.entity) = position;
}

SPTPosition SPTGetPosition(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTPosition>(object.entity);
}

void SPTAddPositionWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<SPTPosition>(object, listener, callback);
}

void SPTRemovePositionWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTPosition>(object, listener, callback);
}

void SPTRemovePositionWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTPosition>(object, listener);
}

simd_float3 SPTGetPositionFromSphericalPosition(SPTSphericalPosition sphericalPosition) {
    float lngSin = sinf(sphericalPosition.longitude);
    float lngCos = cosf(sphericalPosition.longitude);
    float latSin = sinf(sphericalPosition.latitude);
    float latCos = cosf(sphericalPosition.latitude);
    return sphericalPosition.center + sphericalPosition.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);
}

namespace spt {

simd_float3 getPosition(SPTObject object) {
    return getPosition(static_cast<spt::Scene*>(object.sceneHandle)->registry, object.entity);
}

simd_float3 getPosition(const spt::Registry& registry, SPTEntity entity) {
    
    if(const auto position = registry.try_get<SPTPosition>(entity)) {
        switch (position->variantTag) {
            case SPTPositionVariantTagXYZ: {
                return position->xyz;
            }
            case SPTPositionVariantTagSpherical: {
                return SPTGetPositionFromSphericalPosition(position->spherical);
            }
        }
    }
    return {0.f, 0.f, 0.f};
}

}
