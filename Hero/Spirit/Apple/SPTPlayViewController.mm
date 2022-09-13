//
//  SPTPlayViewController.m
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#import "SPTPlayViewController.h"
#import "SPTRenderingContext.h"

#include "PlayableScene.hpp"
#include "AnimatorManager.hpp"
#include "Camera.hpp"
#include "Position.hpp"

@interface SPTPlayViewController () <MTKViewDelegate> {
    SPTAnimatorEvaluationContext _animatorEvaluationContext;
    spt::Renderer _renderer;
}

@end

@implementation SPTPlayViewController

-(instancetype) initWithSceneHandle: (SPTHandle) sceneHandle {
    if (self = [super initWithNibName: nil bundle: nil]) {
        _sceneHandle = sceneHandle;
        _renderingContext = [[SPTRenderingContext alloc] init];
        _renderingContext.screenScale = [UIScreen mainScreen].nativeScale;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mtkView = [[MTKView alloc] initWithFrame: self.view.bounds device: [SPTRenderingContext device]];
    self.mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mtkView.autoResizeDrawable = YES;
    self.mtkView.colorPixelFormat = [SPTRenderingContext colorPixelFormat];
    self.mtkView.depthStencilPixelFormat = [SPTRenderingContext depthPixelFormat];
    self.mtkView.presentsWithTransaction = YES;
    self.mtkView.delegate = self;
    [self.view addSubview: self.mtkView];
    [self updateViewportSize: self.mtkView.drawableSize];
}

// MARK: MTKViewDelegate
-(void) drawInMTKView: (nonnull MTKView*) view {
    
    id<MTLCommandBuffer> commandBuffer = [[SPTRenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"PlayViewRenderCommandBuffer";
    self.renderingContext.commandBuffer = commandBuffer;
        
    [self updateAnimatorEvaluationContext];
    
    auto scene = static_cast<spt::PlayableScene*>(self.sceneHandle);
    scene->update();
    
    scene->evaluateAnimators(_animatorEvaluationContext);
    
    self.renderingContext.cameraPosition = spt::Position::getXYZ(scene->registry, self.viewCameraEntity);
    self.renderingContext.projectionViewMatrix = spt::Camera::getProjectionViewMatrix(scene->registry, self.viewCameraEntity);
    
    if(self.renderingContext.renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
       self.renderingContext.renderPassDescriptor != nil) {
        
        _renderer.render(scene->registry, (__bridge void*) self.renderingContext);
        
        [commandBuffer commit];
        [commandBuffer waitUntilScheduled];
        
        [view.currentDrawable present];
        
        self.renderingContext.renderPassDescriptor = nil;
        
    } else {   
        [commandBuffer commit];
    }
    
}

-(void) mtkView: (nonnull MTKView*) view drawableSizeWillChange: (CGSize) size {
    [self updateViewportSize: size];
}

// MARK: Utils
-(void) updateViewportSize: (CGSize) size {
    self.renderingContext.viewportSize = simd_make_float2(size.width, size.height);
    // Support both options
    auto sceneCpp = static_cast<spt::PlayableScene*>(self.sceneHandle);
    spt::Camera::updatePerspectiveAspectRatio(sceneCpp->registry, self.viewCameraEntity, size.width / size.height);
//    SPTCameraUpdateOrthographicAspectRatio(self.viewCameraEntity, size.width / size.height);
}

-(void) updateAnimatorEvaluationContext {
    if(self.panLocation == nil) {
        _animatorEvaluationContext.panLocation = simd_make_float2(0.f, 0.f);
    } else {
        CGPoint loc = [self.panLocation CGPointValue];
        _animatorEvaluationContext.panLocation = simd_make_float2(loc.x / self.view.bounds.size.width, 1.0 - loc.y / self.view.bounds.size.height);
    }
}

@end
