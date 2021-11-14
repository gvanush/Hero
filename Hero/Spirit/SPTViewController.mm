//
//  SPTViewController.m
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#import "SPTViewController.h"
#import "RenderingContext.h"

#include "Scene.hpp"

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
    commandBuffer.label = @"MyCommand";
    self.renderingContext.commandBuffer = commandBuffer;
    
    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    renderEncoder.label = @"MyRenderEncoder";
    self.renderingContext.renderCommandEncoder = renderEncoder;
    
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
//    scene.viewCamera.camera!.aspectRatio = Float(size.width / size.height)
}

@end
