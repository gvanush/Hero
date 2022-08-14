//
//  Position.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Position.h"
#include "Position.hpp"
#include "Scene.hpp"
#include "ComponentObserverUtil.hpp"


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
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyWillEmergeComponentObservers(registry, object.entity, position);
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
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyWillChangeComponentObservers(registry, object.entity, newPosition);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTPosition>(object.entity) = newPosition;
}

void SPTPositionDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyWillPerishComponentObservers<SPTPosition>(registry, object.entity);
    registry.erase<SPTPosition>(object.entity);
}

SPTPosition SPTPositionGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTPosition>(object.entity);
}

simd_float3 SPTPositionGetXYZ(SPTObject object) {
    return spt::Position::getXYZ(spt::Scene::getRegistry(object), object.entity);
}

const SPTPosition* _Nullable SPTPositionTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTPosition>(object.entity);
}

bool SPTPositionExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTPosition>(object.entity);
}

SPTComponentObserverToken SPTPositionAddWillChangeObserver(SPTObject object, SPTPositionWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveWillChangeObserver(SPTObject object, SPTComponentObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTPosition>(object, token);
}

SPTComponentObserverToken SPTPositionAddWillEmergeObserver(SPTObject object, SPTPositionWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveWillEmergeObserver(SPTObject object, SPTComponentObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTPosition>(object, token);
}

SPTComponentObserverToken SPTPositionAddWillPerishObserver(SPTObject object, SPTPositionWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveWillPerishObserver(SPTObject object, SPTComponentObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTPosition>(object, token);
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
