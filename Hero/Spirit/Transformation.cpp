//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.hpp"
#include "Position.h"
#include "Position.hpp"
#include "Orientation.hpp"
#include "Scale.hpp"
#include "Scene.hpp"
#include "ComponentObserverUtil.hpp"
#include "Base.hpp"
#include "Matrix.h"
#include "Matrix+Orientation.h"

#include <queue>

namespace spt {

namespace {

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    
    const auto& scale = spt::Scale::getXYZ(registry, entity);
    matrix.columns[0][0] = scale.x;
    matrix.columns[1][1] = scale.y;
    matrix.columns[2][2] = scale.z;
    
    const auto& pos = Position::getCartesianCoordinates(registry, entity);
    
    matrix = simd_mul(SPTMatrix4x4CreateUpperLeft(Orientation::getMatrix(registry, entity, pos)), matrix);
    
    matrix.columns[3].xyz = pos;
    
    return matrix;
}

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity, const Transformation::AnimatorRecord& animRecord, const std::vector<float> animatorValues) {
    
    auto matrix = matrix_identity_float4x4;
    
    auto scale = animRecord.baseScale;
    switch (scale.model) {
        case SPTScaleModelXYZ:
            if(animRecord.scaleRecord.xyz.x.index != 0) {
                scale.xyz.x = evaluateAnimatorBinding(animRecord.scaleRecord.xyz.x.binding, animatorValues[animRecord.scaleRecord.xyz.x.index]);
            }
            
            if(animRecord.scaleRecord.xyz.y.index != 0) {
                scale.xyz.y = evaluateAnimatorBinding(animRecord.scaleRecord.xyz.y.binding, animatorValues[animRecord.scaleRecord.xyz.y.index]);
            }
            
            if(animRecord.scaleRecord.xyz.z.index != 0) {
                scale.xyz.z = evaluateAnimatorBinding(animRecord.scaleRecord.xyz.z.binding, animatorValues[animRecord.scaleRecord.xyz.z.index]);
            }
            
            matrix.columns[0][0] = scale.xyz.x;
            matrix.columns[1][1] = scale.xyz.y;
            matrix.columns[2][2] = scale.xyz.z;
            
            break;
        case SPTScaleModelUniform:
            
            if(animRecord.scaleRecord.uniform.index != 0) {
                scale.uniform = evaluateAnimatorBinding(animRecord.scaleRecord.uniform.binding, animatorValues[animRecord.scaleRecord.uniform.index]);
            }
            
            matrix.columns[0][0] = scale.uniform;
            matrix.columns[1][1] = scale.uniform;
            matrix.columns[2][2] = scale.uniform;
            
            break;
    }
    
    auto orientation = animRecord.baseOrientation;
    switch (orientation.model) {
        case SPTOrientationModelEulerXYZ:
        case SPTOrientationModelEulerXZY:
        case SPTOrientationModelEulerYXZ:
        case SPTOrientationModelEulerYZX:
        case SPTOrientationModelEulerZXY:
        case SPTOrientationModelEulerZYX:
            orientation.euler.x += evaluateAnimatorBinding(animRecord.orientationRecord.euler.x.binding, animatorValues[animRecord.orientationRecord.euler.x.index]);
            orientation.euler.y += evaluateAnimatorBinding(animRecord.orientationRecord.euler.y.binding, animatorValues[animRecord.orientationRecord.euler.y.index]);
            orientation.euler.z += evaluateAnimatorBinding(animRecord.orientationRecord.euler.z.binding, animatorValues[animRecord.orientationRecord.euler.z.index]);
            break;
        default:
            assert(false);
            break;
    }
    
    matrix = simd_mul(SPTMatrix4x4CreateUpperLeft(SPTOrientationGetMatrix(orientation)), matrix);
    
    auto position = animRecord.basePosition;
    
    switch (position.coordinateSystem) {
        case SPTCoordinateSystemCartesian:
            
            position.cartesian.x += evaluateAnimatorBinding(animRecord.positionRecord.cartesian.x.binding, animatorValues[animRecord.positionRecord.cartesian.x.index]);
            position.cartesian.y += evaluateAnimatorBinding(animRecord.positionRecord.cartesian.y.binding, animatorValues[animRecord.positionRecord.cartesian.y.index]);
            position.cartesian.z += evaluateAnimatorBinding(animRecord.positionRecord.cartesian.z.binding, animatorValues[animRecord.positionRecord.cartesian.z.index]);
            matrix.columns[3].xyz = position.cartesian;
            
            break;
        case SPTCoordinateSystemLinear:
            
            position.linear.offset += evaluateAnimatorBinding(animRecord.positionRecord.linear.offset.binding, animatorValues[animRecord.positionRecord.linear.offset.index]);
            matrix.columns[3].xyz = SPTLinearCoordinatesToCartesian(position.linear);
            
            break;
        case SPTCoordinateSystemSpherical:
            
            position.spherical.radius += evaluateAnimatorBinding(animRecord.positionRecord.spherical.radius.binding, animatorValues[animRecord.positionRecord.spherical.radius.index]);
            position.spherical.longitude += evaluateAnimatorBinding(animRecord.positionRecord.spherical.longitude.binding, animatorValues[animRecord.positionRecord.spherical.longitude.index]);
            position.spherical.latitude += evaluateAnimatorBinding(animRecord.positionRecord.spherical.latitude.binding, animatorValues[animRecord.positionRecord.spherical.latitude.index]);
            matrix.columns[3].xyz = SPTSphericalCoordinatesToCartesian(position.spherical);
            
            break;
        case SPTCoordinateSystemCylindrical:
            
            position.cylindrical.radius += evaluateAnimatorBinding(animRecord.positionRecord.cylindrical.radius.binding, animatorValues[animRecord.positionRecord.cylindrical.radius.index]);
            position.cylindrical.longitude += evaluateAnimatorBinding(animRecord.positionRecord.cylindrical.longitude.binding, animatorValues[animRecord.positionRecord.cylindrical.longitude.index]);
            position.cylindrical.height += evaluateAnimatorBinding(animRecord.positionRecord.cylindrical.height.binding, animatorValues[animRecord.positionRecord.cylindrical.height.index]);
            matrix.columns[3].xyz = SPTCylindricalCoordinatesToCartesian(position.cylindrical);
            
            break;
    }
    
    return matrix;
}

void updateGlobalMatrix(Registry& registry, Transformation& tran) {
    
    if(tran.node.parent == kSPTNullEntity) {
        tran.global = tran.local;
    } else {
        tran.global = simd_mul(registry.get<Transformation>(tran.node.parent).global, tran.local);
    }
    
    tran.isGlobalMirroring = (simd_determinant(SPTMatrix4x4GetUpperLeft(tran.global)) < 0.f);
}

void updateGlobalMatrix(Transformation& tran, const Transformation& parentTran) {
    tran.global = simd_mul(parentTran.global, tran.local);
    tran.isGlobalMirroring = (simd_determinant(SPTMatrix4x4GetUpperLeft(tran.global)) < 0.f);
}

void removeFromParent(Registry& registry, SPTEntity entity, const Transformation& tran) {
    if(tran.node.parent == kSPTNullEntity) {
        return;
    }
    
    auto& oldParentTran = registry.get<spt::Transformation>(tran.node.parent);
    if(oldParentTran.node.firstChild == entity) {
        oldParentTran.node.firstChild = tran.node.nextSibling;
    }
    if(tran.node.nextSibling != kSPTNullEntity) {
        auto& nextSiblingTran = registry.get<spt::Transformation>(tran.node.nextSibling);
        nextSiblingTran.node.prevSibling = tran.node.prevSibling;
    }
    if(tran.node.prevSibling != kSPTNullEntity) {
        auto& prevSiblingTran = registry.get<spt::Transformation>(tran.node.prevSibling);
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
        nextEntity = registry.get<spt::Transformation>(nextEntity).node.parent;
    }
    
    return result;
}

void Transformation::updateWithoutAnimators(Registry& registry, GroupType& group) {
    
    // Sort so that parents are updated before their children
    group.sort<Transformation>([] (const auto& lhs, const auto& rhs) {
        return lhs.node.level < rhs.node.level;
    });
    
    // Recalculate matrices
    group.each([&registry, &group] (const auto entity, Transformation& tran) {
        
        tran.local = computeTransformationMatrix(registry, entity);
        updateGlobalMatrix(registry, tran);
        
        // Update subtree
        // Prefering iterative over recursive algorithm to avoid stack overflow
        std::queue<SPTEntity> entityQueue;
        entityQueue.push(entity);
        while (!entityQueue.empty()) {

            const auto& parentTran = registry.get<Transformation>(entityQueue.front());
            forEachChild(registry, entityQueue.front(), [&registry, &entityQueue, &parentTran, &group] (auto childEntity, Transformation& childTran) {
                // If child is dirty it will be updated as part of outer loop
                if(!group.contains(childEntity)) {
                    updateGlobalMatrix(childTran, parentTran);
                    entityQueue.push(childEntity);
                }
            });
            
            entityQueue.pop();
        }
        
    });
    
    registry.clear<DirtyTransformationFlag>();
}

void Transformation::updateWithOnlyAnimatorsChanging(Registry& registry, AnimatorsGroupType& group, const std::vector<float> animatorValues) {
    
    group.each([&registry, &group, &animatorValues] (const auto entity, AnimatorRecord& animRecord, Transformation& tran) {
        
        tran.local = computeTransformationMatrix(registry, entity, animRecord, animatorValues);
        updateGlobalMatrix(registry, tran);
        
        // Update subtree
        // Prefering iterative over recursive algorithm to avoid stack overflow
        std::queue<SPTEntity> entityQueue;
        entityQueue.push(entity);
        while (!entityQueue.empty()) {

            const auto& parentTran = registry.get<Transformation>(entityQueue.front());
            forEachChild(registry, entityQueue.front(), [&registry, &entityQueue, &parentTran, &group] (auto childEntity, Transformation& childTran) {
                // If child has animators bound it will be updated as part of outer loop
                if(!group.contains(childEntity)) {
                    updateGlobalMatrix(childTran, parentTran);
                    entityQueue.push(childEntity);
                }
            });
            
            entityQueue.pop();
        }
        
    });
    
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
    return SPTTranformationNode {kSPTNullEntity, kSPTNullEntity, kSPTNullEntity, kSPTNullEntity};
}

void SPTTransformationSetParent(SPTObject object, SPTEntity parentEntity) {
    assert(object.entity != parentEntity);
    assert(!SPTIsNull(object));
    assert(!SPTTransformationIsDescendant(SPTObject {parentEntity, object.sceneHandle}, object));
    
    auto& registry = spt::Scene::getRegistry(object);
    assert(parentEntity == kSPTNullEntity || registry.valid(parentEntity));
    
    auto& tran = registry.get<spt::Transformation>(object.entity);
    
    if(tran.node.parent == parentEntity) {
        return;
    }
    
    // Remove from current parent
    spt::removeFromParent(registry, object.entity, tran);
    
    // Add to new parent
    tran.node.prevSibling = kSPTNullEntity;
    if(parentEntity == kSPTNullEntity) {
        tran.node.nextSibling = kSPTNullEntity;
        tran.node.level = 0;
    } else {
        auto& parentTran = registry.get<spt::Transformation>(parentEntity);
        tran.node.nextSibling = parentTran.node.firstChild;
        
        if(parentTran.node.firstChild != kSPTNullEntity) {
            auto& firstChildTran = registry.get<spt::Transformation>(parentTran.node.firstChild);
            firstChildTran.node.prevSibling = object.entity;
        }
        
        parentTran.node.firstChild = object.entity;
        ++parentTran.node.childrenCount;
        tran.node.level = parentTran.node.level + 1;
    }
    
    tran.node.parent = parentEntity;
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
}

bool SPTTransformationIsDescendant(SPTObject object, SPTObject ancestor) {
    assert(object.sceneHandle == ancestor.sceneHandle);
    assert(!SPTIsNull(ancestor));
    
    const auto& registry = spt::Scene::getRegistry(object);
    auto nextAncestorEntity = object.entity;
    while (nextAncestorEntity != kSPTNullEntity) {
        nextAncestorEntity = registry.get<spt::Transformation>(nextAncestorEntity).node.parent;
        if(nextAncestorEntity == ancestor.entity) {
            return true;
        }
    }
    return false;
}

simd_float4x4 SPTTransformationGetLocal(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.get<spt::Transformation>(object.entity).local;
}
