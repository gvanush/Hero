//
//  Scale.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Scale.h"
#include "Scale.hpp"
#include "ComponentListenerUtil.hpp"
#include "ComponentUpdateNotifier.hpp"
#include "Base.hpp"

void SPTMakeScale(SPTObject object, simd_float3 scale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    registry.emplace<spt::Scale>(object.entity, scale);
}

void SPTUpdateScale(SPTObject object, simd_float3 scale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<spt::Scale>::onWillChange(registry, object.entity);
    
    registry.get<spt::TransformationMatrix>(object.entity).isDirty = true;
    registry.get<spt::Scale>(object.entity).float3 = scale;
}

simd_float3 SPTGetScale(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<spt::Scale>(object.entity).float3;
}

void SPTAddScaleWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<spt::Scale>(object, listener, callback);
}

void SPTRemoveScaleWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<spt::Scale>(object, listener, callback);
}

void SPTRemoveScaleWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<spt::Scale>(object, listener);
}
