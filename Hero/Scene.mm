//
//  Scene.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "Scene.h"
#import "RenderingContext.h"
#import "Camera.h"

#include "Scene.hpp"
#include "SceneObject.hpp"

namespace hero {

class RenderingContext;
class Camera;

}

@interface Scene () {
    NSMutableArray* _sceneObjects;
}

@end

@implementation Scene

-(instancetype) init {
    if (self = [super initWithCpp: new hero::Scene {}]) {
        _sceneObjects = [NSMutableArray array];
        _viewCamera = [[Camera alloc] initWithNear: 0.01f far: 1000.f aspectRatio: 1.f];
        self.cpp->setViewCamera(_viewCamera.cpp);
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
}

-(void) addSceneObject: (SceneObject*) sceneObject {
    [_sceneObjects addObject: sceneObject];
    self.cpp->addSceneObject(sceneObject.cpp);
}

-(SceneObject* _Nullable) rayCast {
    return self.cpp->raycast()->objC<SceneObject*>();
}

-(void) render: (RenderingContext*) renderingContext {
    self.cpp->render(*renderingContext.cpp);
}

-(void) setBgrColor: (simd_float4) bgrColor {
    self.cpp->setBgrColor(bgrColor);
}

-(simd_float4) bgrColor {
    return self.cpp->bgrColor();
}

-(void) setSize: (simd_float2) size {
    self.cpp->setSize(size);
}

-(simd_float2) size {
    return self.cpp->size();
}

-(NSArray*) sceneObjects {
    return _sceneObjects;
}

-(void)setSelectedObject:(SceneObject *)selectedObject {
    self.cpp->setSelectedObject(selectedObject.cpp);
}

-(SceneObject* _Nullable) selectedObject {
    if (auto selected = self.cpp->selectedObject(); selected) {
        return selected->objC<SceneObject*>();
    }
    return nil;
}

+(void) setup {
    hero::Scene::setup();
}

@end

@implementation Scene (Cpp)

-(hero::Scene*) cpp {
    return static_cast<hero::Scene*>(self.cppHandle);
}

@end
