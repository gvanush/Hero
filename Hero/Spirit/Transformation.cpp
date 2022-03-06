//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.hpp"
#include "Position.h"
#include "Position.hpp"
#include "Orientation.h"
#include "Scale.hpp"
#include "Scene.hpp"
#include "ComponentListenerUtil.hpp"
#include "Base.hpp"

#include <queue>

namespace spt {

namespace {

simd_float3x3 computeRotationXMatrix(float rx) {
    const auto c = cosf(rx);
    const auto s = sinf(rx);
    return simd_float3x3 {
        simd_float3 {1.f, 0.f, 0.f},
        simd_float3 {0.f, c, s},
        simd_float3 {0.f, -s, c}
    };
}

simd_float3x3 computeRotationYMatrix(float ry) {
    const auto c = cosf(ry);
    const auto s = sinf(ry);
    return simd_float3x3 {
        simd_float3 {c, 0.f, -s},
        simd_float3 {0.f, 1.f, 0.f},
        simd_float3 {s, 0.f, c}
    };
}

simd_float3x3 computeRotationZMatrix(float rz) {
    const auto c = cosf(rz);
    const auto s = sinf(rz);
    return simd_float3x3 {
        simd_float3 {c, s, 0.f},
        simd_float3 {-s, c, 0.f},
        simd_float3 {0.f, 0.f, 1.f}
    };
}

void applyEulerOrientationMatrix(const SPTEulerOrientation& eulerOrientation, simd_float4x4& matrix) {
    
    auto xMat = computeRotationXMatrix(eulerOrientation.rotation.x);
    auto yMat = computeRotationYMatrix(eulerOrientation.rotation.y);
    auto zMat = computeRotationZMatrix(eulerOrientation.rotation.z);
    
    auto rotMat = matrix_identity_float3x3;
    
    switch (eulerOrientation.order) {
        case SPTEulerOrderXYZ:
            rotMat = simd_mul(zMat, simd_mul(yMat, xMat));
            break;
        case SPTEulerOrderXZY:
            rotMat = simd_mul(yMat, simd_mul(zMat, xMat));
            break;
        case SPTEulerOrderYXZ:
            rotMat = simd_mul(zMat, simd_mul(xMat, yMat));
            break;
        case SPTEulerOrderYZX:
            rotMat = simd_mul(xMat, simd_mul(zMat, yMat));
            break;
        case SPTEulerOrderZXY:
            rotMat = simd_mul(yMat, simd_mul(xMat, zMat));
            break;
        case SPTEulerOrderZYX:
            rotMat = simd_mul(xMat, simd_mul(yMat, zMat));
            break;
    }
    
    matrix.columns[0] = simd_make_float4(rotMat.columns[0], matrix.columns[0][3]);
    matrix.columns[1] = simd_make_float4(rotMat.columns[1], matrix.columns[1][3]);
    matrix.columns[2] = simd_make_float4(rotMat.columns[2], matrix.columns[2][3]);
}

void applyLookAtMatrix(simd_float3 pos, const SPTLookAtOrientation& lookAtOrientation, simd_float4x4& matrix) {
    const auto sign = (lookAtOrientation.positive ? 1 : -1);
    switch(lookAtOrientation.axis) {
        case SPTAxisX: {
            const auto xAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto yAxis = simd_normalize(simd_cross(lookAtOrientation.up, xAxis));
            matrix.columns[2] = simd_make_float4(simd_normalize(simd_cross(xAxis, yAxis)), matrix.columns[2][3]);
            matrix.columns[0] = simd_make_float4(xAxis, matrix.columns[0][3]);
            matrix.columns[1] = simd_make_float4(yAxis, matrix.columns[1][3]);
            break;
        }
        case SPTAxisY: {
            const auto yAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto zAxis = simd_normalize(simd_cross(lookAtOrientation.up, yAxis));
            matrix.columns[0] = simd_make_float4(simd_normalize(simd_cross(yAxis, zAxis)), matrix.columns[0][3]);
            matrix.columns[2] = simd_make_float4(zAxis, matrix.columns[2][3]);
            matrix.columns[1] = simd_make_float4(yAxis, matrix.columns[1][3]);
            break;
        }
        case SPTAxisZ: {
            const auto zAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto xAxis = simd_normalize(simd_cross(lookAtOrientation.up, zAxis));
            matrix.columns[1] = simd_make_float4(simd_normalize(simd_cross(zAxis, xAxis)), matrix.columns[1][3]);
            matrix.columns[0] = simd_make_float4(xAxis, matrix.columns[0][3]);
            matrix.columns[2] = simd_make_float4(zAxis, matrix.columns[2][3]);
            break;
        }
    }
    
}

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    
    matrix.columns[3].xyz = Position::getXYZ(registry, entity);
    
    if(const auto orientation = registry.try_get<SPTOrientation>(entity)) {
        switch (orientation->variantTag) {
            case SPTOrientationVariantTagEuler: {
                applyEulerOrientationMatrix(orientation->euler, matrix);
                break;
            }
            case SPTOrientationVariantTagLookAt: {
                applyLookAtMatrix(matrix.columns[3].xyz, orientation->lookAt, matrix);
                break;
            }
        }
    }
    
    if(const auto scale = registry.try_get<SPTScale>(entity)) {
        matrix.columns[0] *= scale->xyz.x;
        matrix.columns[1] *= scale->xyz.y;
        matrix.columns[2] *= scale->xyz.z;
    }
    
    return matrix;
}

void removeFromParent(Registry& registry, SPTEntity entity, const Transformation& tran) {
    if(SPTIsNull(tran.node.parent)) {
        return;
    }
    
    auto& oldParentTran = registry.get<spt::Transformation>(tran.node.parent.entity);
    if(oldParentTran.node.firstChild.entity == entity) {
        oldParentTran.node.firstChild = tran.node.nextSibling;
    }
    if(!SPTIsNull(tran.node.nextSibling)) {
        auto& nexSiblingTran = registry.get<spt::Transformation>(tran.node.nextSibling.entity);
        nexSiblingTran.node.prevSibling = tran.node.prevSibling;
    }
    if(!SPTIsNull(tran.node.prevSibling)) {
        auto& prevSiblingTran = registry.get<spt::Transformation>(tran.node.prevSibling.entity);
        prevSiblingTran.node.nextSibling = tran.node.nextSibling;
    }
    --oldParentTran.node.childrenCount;

}

}

simd_float4x4 Transformation::getGlobal(Registry& registry, SPTEntity entity) {
    
    auto nextEntity = entity;
    auto result = matrix_identity_float4x4;
    while (nextEntity != kSPTNullEntity) {
        const auto& local = (registry.all_of<DirtyTransformationFlag>(nextEntity) ?
                             computeTransformationMatrix(registry, nextEntity) :
                             registry.get<spt::Transformation>(nextEntity).local);
        result = simd_mul(local, result);
        nextEntity = registry.get<spt::Transformation>(nextEntity).node.parent.entity;
    }
    
    return result;
}

void Transformation::update(Registry& registry, GroupType& group) {
    
    // Sort so that parents are updated before their children
    group.sort<Transformation>([] (const auto& lhs, const auto& rhs) {
        return lhs.node.level < rhs.node.level;
    });
    
    // Recalculate matrices
    group.each([&registry] (const auto entity, Transformation& tran) {
        
        tran.local = computeTransformationMatrix(registry, entity);
        if(tran.node.parent.entity == kSPTNullEntity) {
            tran.global = tran.local;
        } else {
            tran.global = simd_mul(registry.get<Transformation>(tran.node.parent.entity).global, tran.local);
        }
        
        // Update substree
        // Prefering iterative over recursive algorithm to avoid stack overflow
        // Possibly this can be optimized using vector reserve
        std::queue<SPTEntity> entityQueue;
        entityQueue.push(entity);
        while (!entityQueue.empty()) {

            const auto& parentTran = registry.get<Transformation>(entityQueue.front());
            forEachChild(registry, entityQueue.front(), [&registry, &entityQueue, &parentTran] (auto childEntity, Transformation& childTran) {
                // If child is dirty it will be updated as part of outer lopp
                if(!registry.all_of<DirtyTransformationFlag>(childEntity)) {
                    childTran.global = simd_mul(parentTran.global, childTran.local);
                    entityQueue.push(childEntity);
                }
            });
            
            entityQueue.pop();
        }
        
    });
    
    registry.clear<DirtyTransformationFlag>();
}

void Transformation::onDestroy(spt::Registry& registry, SPTEntity entity) {
    auto& tran = registry.get<Transformation>(entity);
    removeFromParent(registry, entity, tran);
    registry.remove<DirtyTransformationFlag>(entity);
}

}


// MARK: Public
SPTTranformationNode SPTTransformationGetNode(SPTObject object) {
    if(const auto transformation = spt::Scene::getRegistry(object).try_get<spt::Transformation>(object.entity)) {
        return transformation->node;
    }
    return SPTTranformationNode {kSPTNullObject, kSPTNullObject, kSPTNullObject, kSPTNullObject};
}

void SPTTransformationSetParent(SPTObject object, SPTObject parent) {
    assert(object.sceneHandle == parent.sceneHandle);
    assert(object.entity != parent.entity);
    assert(!SPTIsNull(object));
    assert(!SPTTransformationIsDescendant(parent, object));
    
    auto& registry = spt::Scene::getRegistry(object);
    auto& tran = registry.get<spt::Transformation>(object.entity);
    
    if(SPTObjectSameAsObject(tran.node.parent, parent)) {
        return;
    }
    
    // Remove from current parent
    spt::removeFromParent(registry, object.entity, tran);
    
    // Add to new parent
    tran.node.prevSibling = kSPTNullObject;
    if(SPTIsNull(parent)) {
        tran.node.nextSibling = kSPTNullObject;
        tran.node.level = 0;
    } else {
        auto& parentTran = registry.get<spt::Transformation>(parent.entity);
        tran.node.nextSibling = parentTran.node.firstChild;
        
        auto& firstChildTran = registry.get<spt::Transformation>(parentTran.node.firstChild.entity);
        firstChildTran.node.prevSibling = object;
        
        parentTran.node.firstChild = object;
        ++parentTran.node.childrenCount;
        tran.node.level = parentTran.node.level + 1;
    }
    
    tran.node.parent = parent;
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
}

bool SPTTransformationIsDescendant(SPTObject object, SPTObject ancestor) {
    assert(object.sceneHandle == ancestor.sceneHandle);
    assert(!SPTIsNull(ancestor));
    
    const auto& registry = spt::Scene::getRegistry(object);
    auto nextAncestorEntity = object.entity;
    while (nextAncestorEntity != kSPTNullEntity) {
        nextAncestorEntity = registry.get<spt::Transformation>(nextAncestorEntity).node.parent.entity;
        if(nextAncestorEntity == ancestor.entity) {
            return true;
        }
    }
    return false;
}
