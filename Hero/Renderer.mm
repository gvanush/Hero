//
//  Renderer.mm
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "Renderer.h"
#import "UIRepresentable.h"
#import "NSPointerArray+Extensions.h"
#import "RenderingContext.h"
#import "Scene.h"

#include "ComponentRegistry.hpp"
#include "RemovedComponentRegistry.hpp"
#include "Scene.hpp"
#include "Camera.hpp"
#include "LineRenderer.hpp"
#include "ImageRenderer.hpp"

@interface Renderer () {
    NSMapTable<UIRepresentable*, NSPointerArray*>* _uiRepresentableToObservers;
    BOOL _isUpdatingUI;
    RendererFlag _flag;
}

@end

@implementation Renderer

static RendererFlag __allRendererFlags = 0;

-(instancetype) init {
    if (self = [super init]) {
        _uiRepresentableToObservers = [NSMapTable weakToStrongObjectsMapTable];
        _isUpdatingUI = false;
        _flag = 0x1;
        while (_flag) {
            if(!(__allRendererFlags & _flag)) {
                __allRendererFlags |= _flag;
                break;
            }
            _flag <<= 1;
        }
    }
    return self;
}

+(instancetype __nullable) make {
    return [[Renderer alloc] init];
}

-(void) dealloc {
    __allRendererFlags &= ~_flag;
}

#pragma mark - UI update
-(void) addObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
    if (!observers) {
        observers = [NSPointerArray weakObjectsPointerArray];
        [_uiRepresentableToObservers setObject: observers forKey: uiRepresentable];
    }
    [observers addPointer: (__bridge void * _Nonnull)(observer)];
}

-(void) removeObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
    NSUInteger index = [observers indexOfObjectPassingTest:^BOOL(id  _Nonnull object) {
        // Checking for 'nil' is needed becasue if the method is called
        // from the destructor of observer it is alread 'nil' in observers array
        return object == observer || object == nil;
    }];
    if(index != NSNotFound) {
        [observers removePointerAtIndex: index];
    }
}

-(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    [_uiRepresentableToObservers removeObjectForKey: uiRepresentable];
}

+(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable {
    // TODO:
    /*
    for(auto renderer: hero::Renderer::allRenderers()) {
        if (renderer) {
            [renderer->objC<Renderer*>() removeAllObserversFor: uiRepresentable];
        }
    }
     */
}

-(void) render: (Scene*) scene context: (RenderingContext*) context {
    
    auto stepNumber = scene.cpp->stepNumber();
    // TODO: delta time
    scene.cpp->step(0.f);
    
    id<MTLCommandBuffer> commandBuffer = [[RenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"CommandBuffer";
    
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: context.renderPassDescriptor];
    commandEncoder.label = @"SceneRenderCommandEncoder";
    
    [commandEncoder setDepthStencilState: [RenderingContext defaultDepthStencilState]];
    
    context.commandBuffer = commandBuffer;
    context.renderCommandEncoder = commandEncoder;
    context.projectionViewMatrix = scene.cpp->viewCamera()->get<hero::Camera>()->projectionViewMatrix();
    
    hero::ComponentRegistry<hero::LineRenderer>::shared().update((__bridge void* _Nonnull) context);
    hero::ComponentRegistry<hero::ImageRenderer>::shared().update((__bridge void* _Nonnull) context);
    
    [commandEncoder endEncoding];
    
    __weak Scene* weakScene = scene;
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakScene) {
                hero::RemovedComponentRegistry::shared().destroyComponents(*weakScene.cpp, stepNumber);
            }
        });
    }];
    
    [commandBuffer commit];
    
    [commandBuffer waitUntilScheduled];
    
    // UI update
    _isUpdatingUI = true;
    
    for (UIRepresentable* uiRepresentable in _uiRepresentableToObservers) {
        if ([uiRepresentable needsUIUpdate: _flag]) {
            NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
            for (id<UIRepresentableObserver> observer in observers) {
                [observer onUIUpdateRequired];
            }
            [uiRepresentable onUIUpdated: _flag];
        }
    }
    
    _isUpdatingUI = false;
    
}

@end
