//
//  SPTViewController.m
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#import "SPTViewController.h"
#import "RenderingContext.h"

#include "Scene.hpp"
#include "Camera.h"
#include "Camera.hpp"

@interface SPTViewController () <MTKViewDelegate>

@end

@implementation SPTViewController

-(instancetype) initWithScene: (SPTScene*) scene {
    if (self = [super initWithNibName: nil bundle: nil]) {
        _scene = scene;
        _renderingContext = [[RenderingContext alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mtkView = [[MTKView alloc] initWithFrame: self.view.bounds device: [RenderingContext device]];
    self.mtkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mtkView.autoResizeDrawable = YES;
    self.mtkView.colorPixelFormat = [RenderingContext colorPixelFormat];
//    mtkView.depthStencilPixelFormat = RenderingContext.depthPixelFormat()
//    _mtkView.presentsWithTransaction = YES
    self.mtkView.delegate = self;
    [self.view insertSubview: self.mtkView atIndex: 0];
    
    [self updateViewportSize: self.mtkView.drawableSize];
}

// MARK: MTKViewDelegate
-(void) drawInMTKView: (nonnull MTKView*) view {
    
    // IMPROVEMENT: @Vanush preferably this should be done as late as possible (at least after command buffer is created)
    MTLRenderPassDescriptor* renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
    
    if(renderPassDescriptor == nil) {
        return;
    }
    
    self.renderingContext.renderPassDescriptor = renderPassDescriptor;
    
    id<MTLCommandBuffer> commandBuffer = [[RenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"MainCommandBuffer";
    self.renderingContext.commandBuffer = commandBuffer;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    renderEncoder.label = @"MainRenderEncoder";
    [renderEncoder setViewport: MTLViewport{0.0, 0.0, self.renderingContext.viewportSize.x, self.renderingContext.viewportSize.y, 0.0, 1.0 }];
    self.renderingContext.renderCommandEncoder = renderEncoder;
    
    assert(spt_is_valid(self.viewCameraEntity));
    self.renderingContext.projectionViewMatrix = spt::get_projection_matrix(self.viewCameraEntity);
    
    static_cast<spt::Scene*>(self.scene.cpp)->update((__bridge void*) self.renderingContext);
    
    [renderEncoder endEncoding];

    // Schedule a present once the framebuffer is complete using the current drawable.
    [commandBuffer presentDrawable: view.currentDrawable];
    
    [commandBuffer commit];
}

-(void) mtkView: (nonnull MTKView*) view drawableSizeWillChange: (CGSize) size {
    [self updateViewportSize: size];
}

// MARK: Utils
-(void) updateViewportSize: (CGSize) size {
    self.renderingContext.viewportSize = simd_make_float2(size.width, size.height);
    assert(spt_is_valid(self.viewCameraEntity));
    spt_update_perspective_camera_aspect_ratio(self.viewCameraEntity, size.width / size.height);
}

@end
