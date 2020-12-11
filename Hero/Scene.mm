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

@interface Scene () {
    NSMutableArray* _sceneObjects;
}

@end

@implementation Scene

-(instancetype) init {
    return [self initWithOwnedCpp: new hero::Scene {} deleter:^(CppHandle handle) {
        delete static_cast<hero::Scene*>(handle);
    }];
}

-(instancetype)initWithOwnedCpp:(CppHandle) cpp deleter:(CppHandleDeleter)deleter {
    if(self = [super initWithOwnedCpp: cpp deleter: deleter]) {
        _sceneObjects = [NSMutableArray array];
        _viewCamera = [[Camera alloc] initWithNear: 0.01f far: 1000.f aspectRatio: 1.f];
        self.cpp->setViewCamera(_viewCamera.cpp);
    }
    return self;
}

-(void) addSceneObject: (SceneObject*) sceneObject {
    [_sceneObjects addObject: sceneObject];
    self.cpp->addSceneObject(sceneObject.cpp);
}

-(SceneObject* _Nullable) rayCast: (Ray) ray {
    if(auto sceneObject = self.cpp->raycast(ray)) {
        return [[SceneObject alloc] initWithUnownedCpp: sceneObject];
    }
    return nil;
}

-(void) setBgrColor: (simd_float4) bgrColor {
    self.cpp->setBgrColor(bgrColor);
}

-(simd_float4) bgrColor {
    return self.cpp->bgrColor();
}

-(NSArray*) sceneObjects {
    return _sceneObjects;
}

-(void)setSelectedObject:(SceneObject *)selectedObject {
    self.cpp->setSelectedObject(selectedObject.cpp);
}

-(SceneObject* _Nullable) selectedObject {
    if (auto selected = self.cpp->selectedObject(); selected) {
        return [[SceneObject alloc] initWithUnownedCpp: selected];
    }
    return nil;
}

@end

@implementation Scene (Cpp)

-(hero::Scene*) cpp {
    return static_cast<hero::Scene*>(self.cppHandle);
}

@end
