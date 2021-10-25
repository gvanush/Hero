//
//  Scene.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "Scene.h"
#import "Camera.h"

#include "Scene.hpp"
#include "SceneObject.hpp"
#include "Transform.hpp"

@implementation Scene

-(instancetype) init {
    return [self initWithOwnedCpp: new hero::Scene {} deleter:^(void* handle) {
        delete static_cast<hero::Scene*>(handle);
    }];
}

-(instancetype)initWithOwnedCpp:(void*) cpp deleter:(CppDeleter)deleter {
    if(self = [super initWithOwnedCpp: cpp deleter: deleter]) {
    }
    return self;
}

-(SceneObject*) makeObject {
    return [SceneObject wrapperForCpp: self.cpp->makeObject()];
}

-(SceneObject*) makeBasicObject {
    return [SceneObject wrapperForCpp: self.cpp->makeBasicObject()];
}

-(SceneObject*) makeLinePoint1: (simd_float3) point1 point2: (simd_float3) point2 thickness: (float) thickness color: (simd_float4) color {
    return [SceneObject wrapperForCpp: self.cpp->makeLine(point1, point2, thickness, color)];
}

-(SceneObject*) makeLineSegmentPoint1: (simd_float3) point1 point2: (simd_float3) point2 point3: (simd_float3) point3 thickness: (float) thickness color: (simd_float4) color {
    return [SceneObject wrapperForCpp: self.cpp->makeLineSegment(point1, point2, point3, thickness, color)];
}

-(SceneObject*) makeImageObject {
    return [SceneObject wrapperForCpp: self.cpp->makeImage()];
}

-(void) removeObject: (SceneObject*) object {
    self.cpp->removeObject(object.cpp);
}

-(SceneObject* _Nullable) rayCast: (Ray) ray {
    if(auto sceneObject = self.cpp->raycast(ray)) {
        return [SceneObject wrapperForCpp: sceneObject];
    }
    return nil;
}

-(void)setTurnedOn:(BOOL)turnedOn {
    self.cpp->setTurnedOn(turnedOn);
}

-(BOOL)isTurnedOn {
    return self.cpp->isTurnedOn();
}

-(void) setBgrColor: (simd_float4) bgrColor {
    self.cpp->setBgrColor(bgrColor);
}

-(simd_float4) bgrColor {
    return self.cpp->bgrColor();
}

-(SceneObject *)viewCamera {
    return [SceneObject wrapperForCpp: self.cpp->viewCamera()];
}

-(void)setSelectedObject:(SceneObject *)selectedObject {
    self.cpp->setSelectedObject(selectedObject.cpp);
}

-(SceneObject* _Nullable) selectedObject {
    if (auto selected = self.cpp->selectedObject(); selected) {
        return [SceneObject wrapperForCpp: selected];
    }
    return nil;
}

@end

@implementation Scene (Cpp)

-(hero::Scene*) cpp {
    return static_cast<hero::Scene*>(self.cppHandle);
}

@end
