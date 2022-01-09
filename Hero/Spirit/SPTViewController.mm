//
//  SPTViewController.m
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#import "SPTViewController.h"
#import "SPTRenderingContext.h"

#include "Scene.hpp"
#include "Camera.h"
#include "Camera.hpp"
#include "Transformation.hpp"

@interface SPTViewController () <MTKViewDelegate>

@end

@implementation SPTViewController

-(instancetype) initWithScene: (SPTScene*) scene {
    if (self = [super initWithNibName: nil bundle: nil]) {
        _scene = scene;
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
//    _mtkView.presentsWithTransaction = YES
    self.mtkView.delegate = self;
    [self.view insertSubview: self.mtkView atIndex: 0];
    [self updateViewportSize: self.mtkView.drawableSize];
}

-(void) setRenderingPaused: (BOOL) paused {
    if(paused == self.mtkView.paused) {
        return;
    }
    self.mtkView.paused = paused;
    if(!paused) {
        [self updateViewportSize: self.mtkView.drawableSize];
    }
}

// MARK: MTKViewDelegate
-(void) drawInMTKView: (nonnull MTKView*) view {
    
    id<MTLCommandBuffer> commandBuffer = [[SPTRenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"MainCommandBuffer";
    self.renderingContext.commandBuffer = commandBuffer;
    
    assert(SPTIsValid(self.viewCameraObject));
    self.renderingContext.cameraPosition = spt::getPosition(self.viewCameraObject);
    self.renderingContext.projectionViewMatrix = spt::getCameraProjectionViewMatrix(self.viewCameraObject);
    
    // NOTE: Preferably this should be done as late as possible (at least after command buffer is created)
    MTLRenderPassDescriptor* renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil) {
        
        self.renderingContext.renderPassDescriptor = renderPassDescriptor;
        
        static_cast<spt::Scene*>(self.scene.cpp)->render((__bridge void*) self.renderingContext);

        // Schedule a present once the framebuffer is complete using the current drawable.
        [commandBuffer presentDrawable: view.currentDrawable];
        
        self.renderingContext.renderPassDescriptor = nil;
    }
    
    [commandBuffer commit];
}

-(void) mtkView: (nonnull MTKView*) view drawableSizeWillChange: (CGSize) size {
    [self updateViewportSize: size];
}

// MARK: Utils
-(void) updateViewportSize: (CGSize) size {
    self.renderingContext.viewportSize = simd_make_float2(size.width, size.height);
    assert(SPTIsValid(self.viewCameraObject));
    SPTUpdatePerspectiveCameraAspectRatio(self.viewCameraObject, size.width / size.height);
//    SPTUpdateOrthographicCameraAspectRatio(self.viewCameraEntity, size.width / size.height);
}

@end
