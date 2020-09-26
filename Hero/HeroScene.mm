//
//  HeroScene.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "HeroScene.h"
#import "RenderingContext.h"

#include "Scene.hpp"

#include <memory>

@interface HeroScene () {
    std::unique_ptr<hero::Scene> _cpp;
    NSMutableArray* _layers;
}

@end

@implementation HeroScene

-(void) setSize: (simd_float2) size {
    _cpp->setSize(size);
}

-(simd_float2) size {
    return _cpp->size();
}

-(void) setViewportSize: (simd_float2) viewportSize {
    _cpp->setViewportSize(viewportSize);
}

-(simd_float2) viewportSize {
    return _cpp->viewportSize();
}

-(void) setBgrColor: (simd_float4) bgrColor {
    _cpp->setBgrColor(bgrColor);
}

-(simd_float4) bgrColor {
    return _cpp->bgrColor();
}

-(NSArray*) layers {
    return _layers;
}

-(instancetype) init {
    if (self = [super init]) {
        _cpp = std::make_unique<hero::Scene>();
        _layers = [NSMutableArray array];
    }
    return self;
}

-(void) addLayer: (Layer*) layer {
    [_layers addObject: layer];
    _cpp->addLayer(static_cast<hero::Layer*>(layer.cppHandle));
}

-(void) render: (RenderingContext*) renderingContext {
    _cpp->render(static_cast<hero::RenderingContext*>(renderingContext.cppHandle));
}

-(CppHandle) cppHandle {
    return _cpp.get();
}

@end
