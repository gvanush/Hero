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
#include "Matrix+Orientation.h"
#include "Vector.h"

#include <simd/simd.h>


namespace spt::Orientation {

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
        switch (orientation->model) {
            case SPTOrientationModelEulerXYZ: {
                return SPTMatrix3x3CreateEulerXYZOrientation(orientation->euler);
            }
            case SPTOrientationModelEulerXZY: {
                return SPTMatrix3x3CreateEulerXZYOrientation(orientation->euler);
            }
            case SPTOrientationModelEulerYXZ: {
                return SPTMatrix3x3CreateEulerYXZOrientation(orientation->euler);
            }
            case SPTOrientationModelEulerYZX: {
                return SPTMatrix3x3CreateEulerYZXOrientation(orientation->euler);
            }
            case SPTOrientationModelEulerZXY: {
                return SPTMatrix3x3CreateEulerZXYOrientation(orientation->euler);
            }
            case SPTOrientationModelEulerZYX: {
                return SPTMatrix3x3CreateEulerZYXOrientation(orientation->euler);
            }
            case SPTOrientationModelPointAtDirection: {
                return SPTMatrix3x3CreateVectorToVector(SPTVectorGetPositiveDirection(orientation->pointAtDirection.axis), simd_normalize(orientation->pointAtDirection.direction));
            }
            case SPTOrientationModelLookAtPoint: {
                return computeLookAtMatrix(position, orientation->lookAtPoint);
            }
            case SPTOrientationModelLookAtDirection: {
                return computeLookAtDirectionMatrix(orientation->lookAtDirection);
            }
            case SPTOrientationModelXYAxis: {
                return computeXYAxesMatrix(orientation->xyAxes);
            }
            case SPTOrientationModelYZAxis: {
                return computeYZAxesMatrix(orientation->yzAxes);
            }
            case SPTOrientationModelZXAxis: {
                return computeZXAxesMatrix(orientation->zxAxes);
            }
        }
    }
    
    return matrix_identity_float3x3;
}

}

bool SPTPointAtDirectionOrientationEqual(SPTPointAtDirectionOrientation lhs, SPTPointAtDirectionOrientation rhs) {
    return simd_equal(lhs.direction, rhs.direction) && lhs.axis == rhs.axis && lhs.angle == rhs.angle;
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
    if(lhs.model != rhs.model) {
        return false;
    }
    
    switch (lhs.model) {
        case SPTOrientationModelEulerXYZ:
        case SPTOrientationModelEulerXZY:
        case SPTOrientationModelEulerYXZ:
        case SPTOrientationModelEulerYZX:
        case SPTOrientationModelEulerZXY:
        case SPTOrientationModelEulerZYX:
            return simd_equal(lhs.euler, rhs.euler);
        case SPTOrientationModelPointAtDirection:
            return SPTPointAtDirectionOrientationEqual(lhs.pointAtDirection, rhs.pointAtDirection);
        case SPTOrientationModelLookAtPoint:
            return SPTLookAtPointOrientationEqual(lhs.lookAtPoint, rhs.lookAtPoint);
        case SPTOrientationModelLookAtDirection:
            return SPTLookAtDirectionOrientationEqual(lhs.lookAtDirection, rhs.lookAtDirection);
        case SPTOrientationModelXYAxis:
            return SPTXYAxesOrientationEqual(lhs.xyAxes, rhs.xyAxes);
        case SPTOrientationModelYZAxis:
            return SPTYZAxesOrientationEqual(lhs.yzAxes, rhs.yzAxes);
        case SPTOrientationModelZXAxis:
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

simd_float3x3 SPTOrientationGetMatrix(SPTOrientation orientation) {
    switch (orientation.model) {
        case SPTOrientationModelEulerXYZ:
            return SPTMatrix3x3CreateEulerXYZOrientation(orientation.euler);
        case SPTOrientationModelEulerXZY:
            return SPTMatrix3x3CreateEulerXZYOrientation(orientation.euler);
        case SPTOrientationModelEulerYXZ:
            return SPTMatrix3x3CreateEulerYXZOrientation(orientation.euler);
        case SPTOrientationModelEulerYZX:
            return SPTMatrix3x3CreateEulerYZXOrientation(orientation.euler);
        case SPTOrientationModelEulerZXY:
            return  SPTMatrix3x3CreateEulerZXYOrientation(orientation.euler);
        case SPTOrientationModelEulerZYX:
            return SPTMatrix3x3CreateEulerZYXOrientation(orientation.euler);
        case SPTOrientationModelPointAtDirection:
            return SPTMatrix3x3CreateVectorToVector(SPTVectorGetPositiveDirection(orientation.pointAtDirection.axis), simd_normalize(orientation.pointAtDirection.direction));
        default:
            // TODO
            assert(false);
            return matrix_identity_float3x3;
    }
}

SPTOrientation SPTOrientationToEulerXYZ(SPTOrientation orientation) {
    return {SPTOrientationModelEulerXYZ, .euler = SPTMatrix3x3GetEulerXYZOrientationAngles(SPTOrientationGetMatrix(orientation))};
}

SPTOrientation SPTOrientationToEulerXZY(SPTOrientation orientation) {
    return {SPTOrientationModelEulerXZY, .euler = SPTMatrix3x3GetEulerXZYOrientationAngles(SPTOrientationGetMatrix(orientation))};
}

SPTOrientation SPTOrientationToEulerYXZ(SPTOrientation orientation) {
    return {SPTOrientationModelEulerYXZ, .euler = SPTMatrix3x3GetEulerYXZOrientationAngles(SPTOrientationGetMatrix(orientation))};
}

SPTOrientation SPTOrientationToEulerYZX(SPTOrientation orientation) {
    return {SPTOrientationModelEulerYZX, .euler = SPTMatrix3x3GetEulerYZXOrientationAngles(SPTOrientationGetMatrix(orientation))};
}

SPTOrientation SPTOrientationToEulerZXY(SPTOrientation orientation) {
    return {SPTOrientationModelEulerZXY, .euler = SPTMatrix3x3GetEulerZXYOrientationAngles(SPTOrientationGetMatrix(orientation))};
}

SPTOrientation SPTOrientationToEulerZYX(SPTOrientation orientation) {
    return {SPTOrientationModelEulerZYX, .euler = SPTMatrix3x3GetEulerZYXOrientationAngles(SPTOrientationGetMatrix(orientation))};
}

SPTOrientation SPTOrientationToPointAtDirection(SPTOrientation orientation, SPTAxis axis, float directionLength) {
    const auto& matrix = SPTOrientationGetMatrix(orientation);
    
    // TODO (angle is ignored)
    SPTPointAtDirectionOrientation pointAtDirection;
    pointAtDirection.axis = axis;
    pointAtDirection.angle = 0.f;
    switch (axis) {
        case SPTAxisX:
            pointAtDirection.direction = matrix.columns[0];
            break;
        case SPTAxisY:
            pointAtDirection.direction = matrix.columns[1];
            break;
        case SPTAxisZ:
            pointAtDirection.direction = matrix.columns[2];
            break;
    }
    pointAtDirection.direction *= directionLength;
    
    return {.model = SPTOrientationModelPointAtDirection, .pointAtDirection = pointAtDirection};
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
