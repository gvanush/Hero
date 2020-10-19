//
//  HeroScene.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "HeroScene.h"
#import "RenderingContext.h"
#import "Camera.h"

#include "Scene.hpp"

namespace hero {

class RenderingContext;
class Camera;

}

@interface HeroScene () {
    NSMutableArray* _sceneObjects;
}

@end

@implementation HeroScene

-(instancetype) init {
    if (self = [super initWithCppHandle: new hero::Scene {}]) {
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

-(void) render: (RenderingContext*) renderingContext {
    self.cpp->render(*renderingContext.cpp);
}

-(void) setSize: (simd_float2) size {
    self.cpp->setSize(size);
}

-(simd_float2) size {
    return self.cpp->size();
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

+(void) setup {
    hero::Scene::setup();
}

@end

@implementation HeroScene (Cpp)

-(hero::Scene*) cpp {
    return static_cast<hero::Scene*>(self.cppHandle);
}

@end
