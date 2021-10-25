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
#include "TextureRenderer.hpp"

@interface Renderer () {
    NSMapTable<UIRepresentable*, NSPointerArray*>* _uiRepresentableToObservers;
    BOOL _isUpdatingUI;
    RendererFlag _flag;
}

@end

@implementation Renderer

constexpr std::size_t kLimit = sizeof(RendererFlag) * CHAR_BIT;
static __weak Renderer* __allRenderers[kLimit] {};

-(instancetype) init {
    if (self = [super init]) {
        _flag = 0x0;
        for(std::size_t i = 0; i < kLimit; ++i) {
            if (!__allRenderers[i]) {
                __allRenderers[i] = self;
                _flag = (0x1 << i);
                break;
            }
        }
        if (!_flag) {
            return nil;
        }
        _uiRepresentableToObservers = [NSMapTable weakToStrongObjectsMapTable];
        _isUpdatingUI = false;
    }
    return self;
}

+(instancetype __nullable) make {
    return [[Renderer alloc] init];
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
        // from the destructor of observer it is already 'nil' in observers array
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
    for(auto renderer: __allRenderers) {
        if (renderer) {
            [renderer removeAllObserversFor: uiRepresentable];
        }
    }
}

-(void) render: (Scene*) scene context: (RenderingContext*) context {
    
    auto stepNumber = scene.cpp->stepNumber();
    // TODO: delta time
    scene.cpp->step(0.f);
    
    hero::ComponentRegistry<hero::LineRenderer>::shared().cleanRemovedComponents(scene.cpp);
    hero::ComponentRegistry<hero::TextureRenderer>::shared().cleanRemovedComponents(scene.cpp);
    
    context.projectionViewMatrix = scene.cpp->viewCamera()->get<hero::Camera>()->projectionViewMatrix();
    
    // Render
    id<MTLCommandBuffer> commandBuffer = [[RenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"CommandBuffer";
    context.commandBuffer = commandBuffer;
    
    // Content render pass
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: context.renderPassDescriptor];
    commandEncoder.label = @"ContentRenderCommandEncoder";
    
    [commandEncoder setDepthStencilState: [RenderingContext defaultDepthStencilState]];
    
    context.renderCommandEncoder = commandEncoder;
    
    auto contextHandle = (__bridge void*) context;
    hero::ComponentRegistry<hero::LineRenderer>::shared().update(scene.cpp, hero::kLayerContent, contextHandle);
    hero::ComponentRegistry<hero::TextureRenderer>::shared().update(scene.cpp, hero::kLayerContent, contextHandle);
    
    [commandEncoder endEncoding];
    
    // UI render pass
    // Without depth testing for now
    context.renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor: context.renderPassDescriptor];
    commandEncoder.label = @"UIRenderCommandEncoder";
    
    context.renderCommandEncoder = commandEncoder;
    
    hero::ComponentRegistry<hero::LineRenderer>::shared().update(scene.cpp, hero::kLayerUI, contextHandle);
    hero::ComponentRegistry<hero::TextureRenderer>::shared().update(scene.cpp, hero::kLayerUI, contextHandle);
    
    [commandEncoder endEncoding];
    
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> _Nonnull) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Destroying components removed during 'stepNumber' for the scene, additionally
            // strongly capturing 'scene' so that as long as it is being rendered its components must be alive
            hero::RemovedComponentRegistry::shared().destroyComponents(scene.cpp, stepNumber);
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
