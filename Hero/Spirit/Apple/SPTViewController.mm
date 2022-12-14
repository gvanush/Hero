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
#include "Position.hpp"

@interface SPTViewController () <MTKViewDelegate> {
    spt::Renderer _renderer;
}

@end

@implementation SPTViewController

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
    self.mtkView.sampleCount = kMultisamplingSampleCount;
    self.mtkView.delegate = self;
    [self.view addSubview: self.mtkView];
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
    
    auto scene = static_cast<spt::Scene*>(self.sceneHandle);
    scene->update();
    
    self.renderingContext.cameraPosition = spt::Position::getCartesianCoordinates(scene->registry, self.viewCameraEntity);
    self.renderingContext.projectionViewMatrix = spt::Camera::getProjectionViewMatrix(scene->registry, self.viewCameraEntity);
    
    if(self.renderingContext.renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
       self.renderingContext.renderPassDescriptor != nil) {
       
        self.renderingContext.renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStoreAndMultisampleResolve;
        _renderer.render(scene->registry, (__bridge void*) self.renderingContext);
        
        [commandBuffer commit];
        
        [commandBuffer waitUntilScheduled];
        
        [view.currentDrawable present];
        
        self.renderingContext.renderPassDescriptor = nil;
        
    } else {
        [commandBuffer commit];
    }
    
    scene->onPostRender();
}

-(void) mtkView: (nonnull MTKView*) view drawableSizeWillChange: (CGSize) size {
    [self updateViewportSize: size];
}

// MARK: Utils
-(void) updateViewportSize: (CGSize) size {
    self.renderingContext.viewportSize = simd_make_float2(size.width, size.height);
    auto sceneCpp = static_cast<spt::Scene*>(self.sceneHandle);
    spt::Camera::updatePerspectiveAspectRatio(sceneCpp->registry, self.viewCameraEntity, size.width / size.height);
//    SPTCameraUpdateOrthographicAspectRatio(self.viewCameraEntity, size.width / size.height);
}

@end
