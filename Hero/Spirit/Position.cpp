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


bool SPTPositionEqual(SPTPosition lhs, SPTPosition rhs) {
    if(lhs.coordinateSystem != rhs.coordinateSystem) {
        return false;
    }
    
    switch (lhs.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            return simd_equal(lhs.cartesian, rhs.cartesian);
        case SPTCoordinateSystemLinear:
            return SPTLinearCoordinatesEqual(lhs.linear, rhs.linear);
        case SPTCoordinateSystemSpherical:
            return SPTSphericalCoordinatesEqual(lhs.spherical, rhs.spherical);
        case SPTCoordinateSystemCylindrical:
            return SPTCylindricalCoordinatesEqual(lhs.cylindrical, rhs.cylindrical);
    }
}

SPTPosition SPTPositionAdd(SPTPosition lhs, SPTPosition rhs) {
    assert(lhs.coordinateSystem == rhs.coordinateSystem);
    switch (lhs.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            return {SPTCoordinateSystemCartesian, lhs.cartesian + rhs.cartesian};
        case SPTCoordinateSystemLinear:
            return {SPTCoordinateSystemLinear, .linear = SPTLinearCoordinatesAdd(lhs.linear, rhs.linear)};
        case SPTCoordinateSystemSpherical:
            return {SPTCoordinateSystemSpherical, .spherical = SPTSphericalCoordinatesAdd(lhs.spherical, rhs.spherical)};
        case SPTCoordinateSystemCylindrical:
            return {SPTCoordinateSystemCylindrical, .cylindrical = SPTCylindricalCoordinatesAdd(lhs.cylindrical, rhs.cylindrical)};
    }
}

SPTPosition SPTPositionSubtract(SPTPosition lhs, SPTPosition rhs) {
    assert(lhs.coordinateSystem == rhs.coordinateSystem);
    switch (lhs.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            return {SPTCoordinateSystemCartesian, lhs.cartesian + rhs.cartesian};
        case SPTCoordinateSystemLinear:
            return {SPTCoordinateSystemLinear, .linear = SPTLinearCoordinatesSubtract(lhs.linear, rhs.linear)};
        case SPTCoordinateSystemSpherical:
            return {SPTCoordinateSystemSpherical, .spherical = SPTSphericalCoordinatesSubtract(lhs.spherical, rhs.spherical)};
        case SPTCoordinateSystemCylindrical:
            return {SPTCoordinateSystemCylindrical, .cylindrical = SPTCylindricalCoordinatesSubtract(lhs.cylindrical, rhs.cylindrical)};
    }
}

SPTPosition SPTPositionMultiplyScalar(SPTPosition position, float scalar) {
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            position.cartesian *= scalar;
        case SPTCoordinateSystemLinear:
            position.linear = SPTLinearCoordinatesMultiplyScalar(position.linear, scalar);
        case SPTCoordinateSystemSpherical:
            position.spherical = SPTSphericalCoordinatesMultiplyScalar(position.spherical, scalar);
        case SPTCoordinateSystemCylindrical:
            position.cylindrical = SPTCylindricalCoordinatesMultiplyScalar(position.cylindrical, scalar);
    }
    return position;
}

void SPTPositionMake(SPTObject object, SPTPosition position) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTPosition>(object.entity, position);
    spt::notifyComponentDidEmergeObservers(registry, object.entity, position);
}

void SPTPositionUpdate(SPTObject object, SPTPosition newPosition) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newPosition);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    spt::notifyComponentDidChangeObservers(registry, object.entity, spt::update(registry, object.entity, newPosition));
}

void SPTPositionDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTPosition>(registry, object.entity);
    registry.erase<SPTPosition>(object.entity);
}

SPTPosition SPTPositionGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTPosition>(object.entity);
}

const SPTPosition* _Nullable SPTPositionTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTPosition>(object.entity);
}

bool SPTPositionExists(SPTObject object) {
    return spt::Scene::getRegistry(object).all_of<SPTPosition>(object.entity);
}

simd_float3 SPTPositionGetOrigin(SPTPosition position) {
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            return {};
        case SPTCoordinateSystemLinear:
            return position.linear.origin;
        case SPTCoordinateSystemSpherical:
            return position.spherical.origin;
        case SPTCoordinateSystemCylindrical:
            return position.cylindrical.origin;
    }
}

SPTPosition SPTPositionToCartesian(SPTPosition position) {
    simd_float3 cartesian;
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            return position;
        case SPTCoordinateSystemLinear:
            cartesian = SPTLinearCoordinatesToCartesian(position.linear);
            break;
        case SPTCoordinateSystemSpherical:
            cartesian = SPTSphericalCoordinatesToCartesian(position.spherical);
            break;
        case SPTCoordinateSystemCylindrical:
            cartesian = SPTCylindricalCoordinatesToCartesian(position.cylindrical);
            break;
    }
    return {SPTCoordinateSystemCartesian, .cartesian = cartesian};
}

SPTPosition SPTPositionToLinear(SPTPosition position, simd_float3 origin) {
    SPTLinearCoordinates linear;
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            linear = SPTLinearCoordinatesCreate(origin, position.cartesian);
            break;
        case SPTCoordinateSystemLinear:
            linear = SPTLinearCoordinatesCreate(origin, SPTLinearCoordinatesToCartesian(position.linear));
            break;
        case SPTCoordinateSystemSpherical:
            linear = SPTLinearCoordinatesCreate(origin, SPTSphericalCoordinatesToCartesian(position.spherical));
            break;
        case SPTCoordinateSystemCylindrical:
            linear = SPTLinearCoordinatesCreate(origin, SPTCylindricalCoordinatesToCartesian(position.cylindrical));
            break;
    }
    return {SPTCoordinateSystemLinear, .linear = linear};
}

SPTPosition SPTPositionToSpherical(SPTPosition position, simd_float3 origin) {
    SPTSphericalCoordinates spherical;
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            spherical = SPTSphericalCoordinatesCreate(origin, position.cartesian);
            break;
        case SPTCoordinateSystemLinear:
            spherical = SPTSphericalCoordinatesCreate(origin, SPTLinearCoordinatesToCartesian(position.linear));
            break;
        case SPTCoordinateSystemSpherical:
            spherical = SPTSphericalCoordinatesCreate(origin, SPTSphericalCoordinatesToCartesian(position.spherical));
            break;
        case SPTCoordinateSystemCylindrical:
            spherical = SPTSphericalCoordinatesCreate(origin, SPTCylindricalCoordinatesToCartesian(position.cylindrical));
            break;
    }
    return {SPTCoordinateSystemSpherical, .spherical = spherical};
}

SPTPosition SPTPositionToCylindrical(SPTPosition position, simd_float3 origin) {
    SPTCylindricalCoordinates cylindrical;
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            cylindrical = SPTCylindricalCoordinatesCreate(origin, position.cartesian);
            break;
        case SPTCoordinateSystemLinear:
            cylindrical = SPTCylindricalCoordinatesCreate(origin, SPTLinearCoordinatesToCartesian(position.linear));
            break;
        case SPTCoordinateSystemSpherical:
            cylindrical = SPTCylindricalCoordinatesCreate(origin, SPTSphericalCoordinatesToCartesian(position.spherical));
            break;
        case SPTCoordinateSystemCylindrical:
            cylindrical = SPTCylindricalCoordinatesCreate(origin, SPTCylindricalCoordinatesToCartesian(position.cylindrical));
            break;
    }
    return {SPTCoordinateSystemCylindrical, .cylindrical = cylindrical};
}

SPTObserverToken SPTPositionAddWillChangeObserver(SPTObject object, SPTPositionWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTPosition>(object, token);
}

SPTObserverToken SPTPositionAddDidChangeObserver(SPTObject object, SPTPositionDidChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidChangeObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveDidChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidChangeObserver<SPTPosition>(object, token);
}

SPTObserverToken SPTPositionAddDidEmergeObserver(SPTObject object, SPTPositionDidEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidEmergeObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidEmergeObserver<SPTPosition>(object, token);
}

SPTObserverToken SPTPositionAddWillPerishObserver(SPTObject object, SPTPositionWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTPosition>(object, observer, userInfo);
}

void SPTPositionRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTPosition>(object, token);
}


namespace spt {

namespace Position {

simd_float3 getCartesianCoordinates(const spt::Registry& registry, SPTEntity entity) {
    if(const auto position = registry.try_get<SPTPosition>(entity)) {
        switch (position->coordinateSystem) {
            case SPTCoordinateSystemCartesian: {
                return position->cartesian;
            }
            case SPTCoordinateSystemLinear: {
                return SPTLinearCoordinatesToCartesian(position->linear);
            }
            case SPTCoordinateSystemSpherical: {
                return SPTSphericalCoordinatesToCartesian(position->spherical);
            }
            case SPTCoordinateSystemCylindrical: {
                return SPTCylindricalCoordinatesToCartesian(position->cylindrical);
            }
        }
    }
    return {0.f, 0.f, 0.f};
}

}

}
