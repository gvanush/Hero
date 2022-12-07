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
#include "Matrix.h"

#include <simd/simd.h>


namespace spt::Orientation {

simd_float3x3 computeEulerOrientationMatrix(const SPTEulerOrientation& eulerOrientation) {
    
    const auto& xMat = SPTMatrix3x3CreateEulerRotationX(eulerOrientation.rotation.x);
    const auto& yMat = SPTMatrix3x3CreateEulerRotationY(eulerOrientation.rotation.y);
    const auto& zMat = SPTMatrix3x3CreateEulerRotationZ(eulerOrientation.rotation.z);
    
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

simd_float3x3 computeLookAtMatrix(simd_float3 pos, const SPTLookAtPointOrientation& orientation) {
    const auto sign = (orientation.positive ? 1 : -1);
    switch(orientation.axis) {
        case SPTAxisX: {
            const auto xAxis = sign * simd_normalize(orientation.target - pos);
            const auto yAxis = simd_normalize(simd_cross(orientation.up, xAxis));
            
            return simd_float3x3 {
                xAxis,
                yAxis,
                simd_normalize(simd_cross(xAxis, yAxis))
            };
        }
        case SPTAxisY: {
            const auto yAxis = sign * simd_normalize(orientation.target - pos);
            const auto zAxis = simd_normalize(simd_cross(orientation.up, yAxis));
            return simd_float3x3 {
                simd_normalize(simd_cross(yAxis, zAxis)),
                yAxis,
                zAxis
            };
        }
        case SPTAxisZ: {
            const auto zAxis = sign * simd_normalize(orientation.target - pos);
            const auto xAxis = simd_normalize(simd_cross(orientation.up, zAxis));
            return simd_float3x3 {
                xAxis,
                simd_normalize(simd_cross(zAxis, xAxis)),
                zAxis
            };
        }
    }
}

simd_float3x3 computeLookAtDirectionMatrix(const SPTLookAtDirectionOrientation& orientation) {
    const auto sign = (orientation.positive ? 1 : -1);
    switch(orientation.axis) {
        case SPTAxisX: {
            const auto xAxis = sign * orientation.normDirection;
            const auto yAxis = simd_normalize(simd_cross(orientation.up, xAxis));
            
            return simd_float3x3 {
                xAxis,
                yAxis,
                simd_normalize(simd_cross(xAxis, yAxis))
            };
        }
        case SPTAxisY: {
            const auto yAxis = sign * orientation.normDirection;
            const auto zAxis = simd_normalize(simd_cross(orientation.up, yAxis));
            return simd_float3x3 {
                simd_normalize(simd_cross(yAxis, zAxis)),
                yAxis,
                zAxis
            };
        }
        case SPTAxisZ: {
            const auto zAxis = sign * orientation.normDirection;
            const auto xAxis = simd_normalize(simd_cross(orientation.up, zAxis));
            return simd_float3x3 {
                xAxis,
                simd_normalize(simd_cross(zAxis, xAxis)),
                zAxis
            };
        }
    }
}

simd_float3x3 computeXYAxesMatrix(const SPTXYAxesOrientation& orientation) {
    return {
        orientation.orthoNormX,
        orientation.orthoNormY,
        simd_cross(orientation.orthoNormX, orientation.orthoNormY)
    };
}

simd_float3x3 computeYZAxesMatrix(const SPTYZAxesOrientation& orientation) {
    return {
        simd_cross(orientation.orthoNormY, orientation.orthoNormZ),
        orientation.orthoNormY,
        orientation.orthoNormZ
    };
}

simd_float3x3 computeZXAxesMatrix(const SPTZXAxesOrientation& orientation) {
    return {
        orientation.orthoNormX,
        simd_cross(orientation.orthoNormZ, orientation.orthoNormX),
        orientation.orthoNormZ
    };
}

simd_float3x3 getMatrix(const spt::Registry& registry, SPTEntity entity, const simd_float3& position) {
    
    if(const auto orientation = registry.try_get<SPTOrientation>(entity)) {
        switch (orientation->type) {
            case SPTOrientationTypeEuler: {
                return computeEulerOrientationMatrix(orientation->euler);
            }
            case SPTOrientationTypeLookAtPoint: {
                return computeLookAtMatrix(position, orientation->lookAtPoint);
            }
            case SPTOrientationTypeLookAtDirection: {
                return computeLookAtDirectionMatrix(orientation->lookAtDirection);
            }
            case SPTOrientationTypeXYAxis: {
                return computeXYAxesMatrix(orientation->xyAxes);
            }
            case SPTOrientationTypeYZAxis: {
                return computeYZAxesMatrix(orientation->yzAxes);
            }
            case SPTOrientationTypeZXAxis: {
                return computeZXAxesMatrix(orientation->zxAxes);
            }
        }
    }
    
    return matrix_identity_float3x3;
}

}

bool SPTEulerOrientationEqual(SPTEulerOrientation lhs, SPTEulerOrientation rhs) {
    return simd_equal(lhs.rotation, rhs.rotation) && lhs.order == rhs.order;
}

bool SPTLookAtPointOrientationEqual(SPTLookAtPointOrientation lhs, SPTLookAtPointOrientation rhs) {
    return simd_equal(lhs.target, rhs.target) &&
    simd_equal(lhs.up, rhs.up) &&
    lhs.axis == rhs.axis &&
    lhs.positive == rhs.positive;
}

bool SPTLookAtDirectionOrientationEqual(SPTLookAtDirectionOrientation lhs, SPTLookAtDirectionOrientation rhs) {
    return simd_equal(lhs.normDirection, rhs.normDirection) &&
    simd_equal(lhs.up, rhs.up) &&
    lhs.axis == rhs.axis &&
    lhs.positive == rhs.positive;
}

bool SPTXYAxesOrientationEqual(SPTXYAxesOrientation lhs, SPTXYAxesOrientation rhs) {
    return simd_equal(lhs.orthoNormX, rhs.orthoNormX) && simd_equal(lhs.orthoNormY, rhs.orthoNormY);
}

bool SPTYZAxesOrientationEqual(SPTYZAxesOrientation lhs, SPTYZAxesOrientation rhs) {
    return simd_equal(lhs.orthoNormY, rhs.orthoNormY) && simd_equal(lhs.orthoNormZ, rhs.orthoNormZ);
}

bool SPTZXAxesOrientationEqual(SPTZXAxesOrientation lhs, SPTZXAxesOrientation rhs) {
    return simd_equal(lhs.orthoNormZ, rhs.orthoNormZ) && simd_equal(lhs.orthoNormX, rhs.orthoNormX);
}

bool SPTOrientationEqual(SPTOrientation lhs, SPTOrientation rhs) {
    if(lhs.type != rhs.type) {
        return false;
    }
    
    switch (lhs.type) {
        case SPTOrientationTypeEuler:
            return SPTEulerOrientationEqual(lhs.euler, rhs.euler);
        case SPTOrientationTypeLookAtPoint:
            return SPTLookAtPointOrientationEqual(lhs.lookAtPoint, rhs.lookAtPoint);
        case SPTOrientationTypeLookAtDirection:
            return SPTLookAtDirectionOrientationEqual(lhs.lookAtDirection, rhs.lookAtDirection);
        case SPTOrientationTypeXYAxis:
            return SPTXYAxesOrientationEqual(lhs.xyAxes, rhs.xyAxes);
        case SPTOrientationTypeYZAxis:
            return SPTYZAxesOrientationEqual(lhs.yzAxes, rhs.yzAxes);
        case SPTOrientationTypeZXAxis:
            return SPTZXAxesOrientationEqual(lhs.zxAxes, rhs.zxAxes);
    }
}

void SPTOrientationMake(SPTObject object, SPTOrientation orientation) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTOrientation>(object.entity, orientation);
    spt::notifyComponentDidEmergeObservers(registry, object.entity, orientation);
}

void SPTOrientationUpdate(SPTObject object, SPTOrientation newOrientation) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newOrientation);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    spt::notifyComponentDidChangeObservers(registry, object.entity, spt::update(registry, object.entity, newOrientation));
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

SPTObserverToken SPTOrientationAddDidChangeObserver(SPTObject object, SPTOrientationDidChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidChangeObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveDidChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidChangeObserver<SPTOrientation>(object, token);
}

SPTObserverToken SPTOrientationAddDidEmergeObserver(SPTObject object, SPTOrientationDidEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidEmergeObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidEmergeObserver<SPTOrientation>(object, token);
}

SPTObserverToken SPTOrientationAddWillPerishObserver(SPTObject object, SPTOrientationWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTOrientation>(object, token);
}
