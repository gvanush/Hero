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
    NSMutableArray* _layers;
}

@end

@implementation HeroScene

-(instancetype) init {
    if (self = [super initWithCppHandle: new hero::Scene {}]) {
        _layers = [NSMutableArray array];
        _viewCamera = [[Camera alloc] initWithNear: 0.01f far: 1000.f aspectRatio: 1.f];
        self.cpp->setViewCamera(_viewCamera.cpp);
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
}

-(void) addLayer: (Layer*) layer {
    [_layers addObject: layer];
    self.cpp->addLayer(static_cast<hero::Layer*>(layer.cppHandle));
}

-(void) render: (RenderingContext*) renderingContext {
    self.cpp->render(static_cast<hero::RenderingContext*>(renderingContext.cpp));
}

-(void) setSize: (simd_float2) size {
    self.cpp->setSize(size);
}

-(simd_float2) size {
    return self.cpp->size();
}

-(void) setViewportSize: (simd_float2) viewportSize {
    self.cpp->setViewportSize(viewportSize);
    _viewCamera.aspectRatio = viewportSize.x / viewportSize.y;
}

-(simd_float2) viewportSize {
    return self.cpp->viewportSize();
}

-(void) setBgrColor: (simd_float4) bgrColor {
    self.cpp->setBgrColor(bgrColor);
}

-(simd_float4) bgrColor {
    return self.cpp->bgrColor();
}

-(NSArray*) layers {
    return _layers;
}

@end

@implementation HeroScene (Cpp)

-(hero::Scene*) cpp {
    return static_cast<hero::Scene*>(self.cppHandle);
}

@end
