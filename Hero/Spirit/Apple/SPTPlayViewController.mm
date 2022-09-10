//
//  SPTPlayViewController.m
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#import "SPTPlayViewController.h"
#import "SPTRenderingContext.h"

#include "PlayableScene.hpp"
#include "Camera.hpp"
#include "Position.hpp"

@interface SPTPlayViewController () <MTKViewDelegate>

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
    self.mtkView.delegate = self;
    [self.view addSubview: self.mtkView];
    [self updateViewportSize: self.mtkView.drawableSize];
}

-(void)setPanLocation:(NSValue *)panLocation {
    if(panLocation == nil) {
        NSLog(@"panLocation nil");
    } else {
        NSLog(@"panLocation %@", NSStringFromCGPoint(panLocation.CGPointValue));
    }
}

// MARK: MTKViewDelegate
-(void) drawInMTKView: (nonnull MTKView*) view {
    
    id<MTLCommandBuffer> commandBuffer = [[SPTRenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"PlayViewRenderCommandBuffer";
    self.renderingContext.commandBuffer = commandBuffer;
    
    auto sceneCpp = static_cast<spt::PlayableScene*>(self.sceneHandle);
//    scene->onPrerender();
    
    self.renderingContext.cameraPosition = spt::Position::getXYZ(sceneCpp->registry, self.viewCameraEntity);
    self.renderingContext.projectionViewMatrix = spt::Camera::getProjectionViewMatrix(sceneCpp->registry, self.viewCameraEntity);
    
    MTLRenderPassDescriptor* renderPassDescriptor = self.mtkView.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil) {
        
        self.renderingContext.renderPassDescriptor = renderPassDescriptor;
        
        sceneCpp->render((__bridge void*) self.renderingContext);
        
        [commandBuffer presentDrawable: view.currentDrawable];
        
        [commandBuffer commit];
        
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

@end
