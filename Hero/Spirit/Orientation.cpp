//
//  Orientation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Orientation.hpp"
#include "Scene.hpp"
#include "Transformation.hpp"
#include "ComponentObserverUtil.hpp"

#include <simd/simd.h>


namespace spt::Orientation {

simd_float4x4 computeRotationXMatrix(float rx) {
    const auto c = cosf(rx);
    const auto s = sinf(rx);
    return simd_float4x4 {
        simd_float4 {1.f, 0.f, 0.f, 0.f},
        simd_float4 {0.f, c, s, 0.f},
        simd_float4 {0.f, -s, c, 0.f},
        simd_float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd_float4x4 computeRotationYMatrix(float ry) {
    const auto c = cosf(ry);
    const auto s = sinf(ry);
    return simd_float4x4 {
        simd_float4 {c, 0.f, -s, 0.f},
        simd_float4 {0.f, 1.f, 0.f, 0.f},
        simd_float4 {s, 0.f, c, 0.f},
        simd_float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd_float4x4 computeRotationZMatrix(float rz) {
    const auto c = cosf(rz);
    const auto s = sinf(rz);
    return simd_float4x4 {
        simd_float4 {c, s, 0.f, 0.f},
        simd_float4 {-s, c, 0.f, 0.f},
        simd_float4 {0.f, 0.f, 1.f, 0.f},
        simd_float4 {0.f, 0.f, 0.f, 1.f}
    };
}

simd_float4x4 computeEulerOrientationMatrix(const SPTEulerOrientation& eulerOrientation) {
    
    const auto& xMat = computeRotationXMatrix(eulerOrientation.rotation.x);
    const auto& yMat = computeRotationYMatrix(eulerOrientation.rotation.y);
    const auto& zMat = computeRotationZMatrix(eulerOrientation.rotation.z);
    
    switch (eulerOrientation.order) {
        case SPTEulerOrderXYZ:
            return simd_mul(zMat, simd_mul(yMat, xMat));
        case SPTEulerOrderXZY:
            return simd_mul(yMat, simd_mul(zMat, xMat));
        case SPTEulerOrderYXZ:
            return simd_mul(zMat, simd_mul(xMat, yMat));
        case SPTEulerOrderYZX:
            return simd_mul(xMat, simd_mul(zMat, yMat));
        case SPTEulerOrderZXY:
            return simd_mul(yMat, simd_mul(xMat, zMat));
        case SPTEulerOrderZYX:
            return simd_mul(xMat, simd_mul(yMat, zMat));
    }
}

simd_float4x4 computeLookAtMatrix(simd_float3 pos, const SPTLookAtOrientation& lookAtOrientation) {
    const auto sign = (lookAtOrientation.positive ? 1 : -1);
    switch(lookAtOrientation.axis) {
        case SPTAxisX: {
            const auto xAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto yAxis = simd_normalize(simd_cross(lookAtOrientation.up, xAxis));
            
            return simd_float4x4 {
                simd_make_float4(xAxis, 0.f),
                simd_make_float4(yAxis, 0.f),
                simd_make_float4(simd_normalize(simd_cross(xAxis, yAxis)), 0.f),
                simd_float4 {0.f, 0.f, 0.f, 1.f}
            };
        }
        case SPTAxisY: {
            const auto yAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto zAxis = simd_normalize(simd_cross(lookAtOrientation.up, yAxis));
            return simd_float4x4 {
                simd_make_float4(simd_normalize(simd_cross(yAxis, zAxis)), 0.f),
                simd_make_float4(yAxis, 0.f),
                simd_make_float4(zAxis, 0.f),
                simd_float4 {0.f, 0.f, 0.f, 1.f}
            };
        }
        case SPTAxisZ: {
            const auto zAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto xAxis = simd_normalize(simd_cross(lookAtOrientation.up, zAxis));
            return simd_float4x4 {
                simd_make_float4(xAxis, 0.f),
                simd_make_float4(simd_normalize(simd_cross(zAxis, xAxis)), 0.f),
                simd_make_float4(zAxis, 0.f),
                simd_float4 {0.f, 0.f, 0.f, 1.f}
            };
        }
    }
    
}

simd_float4x4 getMatrix(const spt::Registry& registry, SPTEntity entity, const simd_float3& position) {
    
    if(const auto orientation = registry.try_get<SPTOrientation>(entity)) {
        switch (orientation->type) {
            case SPTOrientationTypeEuler: {
                return computeEulerOrientationMatrix(orientation->euler);
            }
            case SPTOrientationTypeLookAt: {
                return computeLookAtMatrix(position, orientation->lookAt);
            }
        }
    }
    
    return matrix_identity_float4x4;
}

}

bool SPTEulerOrientationEqual(SPTEulerOrientation lhs, SPTEulerOrientation rhs) {
    return simd_equal(lhs.rotation, rhs.rotation) && lhs.order == rhs.order;
}

bool SPTLookAtOrientationEqual(SPTLookAtOrientation lhs, SPTLookAtOrientation rhs) {
    return simd_equal(lhs.target, rhs.target) &&
    simd_equal(lhs.up, rhs.up) &&
    lhs.axis == rhs.axis &&
    lhs.positive == rhs.positive;
}

bool SPTOrientationEqual(SPTOrientation lhs, SPTOrientation rhs) {
    if(lhs.type != rhs.type) {
        return false;
    }
    
    switch (lhs.type) {
        case SPTOrientationTypeEuler:
            return SPTEulerOrientationEqual(lhs.euler, rhs.euler);
        case SPTOrientationTypeLookAt:
            return SPTLookAtOrientationEqual(lhs.lookAt, rhs.lookAt);
    }
}

void SPTOrientationMake(SPTObject object, SPTOrientation orientation) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillEmergeObservers(registry, object.entity, orientation);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTOrientation>(object.entity, orientation);
}

void SPTOrientationUpdate(SPTObject object, SPTOrientation newOrientation) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newOrientation);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTOrientation>(object.entity) = newOrientation;
}

void SPTOrientationDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTOrientation>(registry, object.entity);
    registry.erase<SPTOrientation>(object.entity);
}

const SPTOrientation* _Nullable SPTOrientationTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTOrientation>(object.entity);
}

SPTOrientation SPTOrientationGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTOrientation>(object.entity);
}

bool SPTOrientationExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTOrientation>(object.entity);
}

SPTObserverToken SPTOrientationAddWillChangeObserver(SPTObject object, SPTOrientationWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTOrientation>(object, token);
}

SPTObserverToken SPTOrientationAddWillEmergeObserver(SPTObject object, SPTOrientationWillEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTOrientation>(object, token);
}

SPTObserverToken SPTOrientationAddWillPerishObserver(SPTObject object, SPTOrientationWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTOrientation>(object, token);
}
