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
    CFTimeInterval _startTime;
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

- (void) viewDidLoad {
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
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onApplicationWillResignActive) name: UIApplicationWillResignActiveNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(onApplicationDidBecomeActive) name: UIApplicationDidBecomeActiveNotification object: nil];
}

-(void) setRenderingPaused: (BOOL) renderingPaused {
    if(self.renderingPaused == renderingPaused) {
        return;
    }
    _renderingPaused = renderingPaused;
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        self.mtkView.paused = renderingPaused;
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    _startTime = CACurrentMediaTime();
}

// MARK: MTKViewDelegate
-(void) drawInMTKView: (nonnull MTKView*) view {
    
    id<MTLCommandBuffer> commandBuffer = [[SPTRenderingContext defaultCommandQueue] commandBuffer];
    commandBuffer.label = @"MainCommandBuffer";
    self.renderingContext.commandBuffer = commandBuffer;
    
    auto scene = static_cast<spt::Scene*>(self.sceneHandle);
    scene->update(CACurrentMediaTime() - _startTime);
    
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
    
}

-(void) mtkView: (nonnull MTKView*) view drawableSizeWillChange: (CGSize) size {
    [self updateViewportSize: size];
}

// MARK: Application lifecycle
-(void) onApplicationWillResignActive {
    self.mtkView.paused = YES;
}

-(void) onApplicationDidBecomeActive {
    self.mtkView.paused = self.isRenderingPaused;
}

// MARK: Utils
-(void) updateViewportSize: (CGSize) size {
    self.renderingContext.viewportSize = simd_make_float2(size.width, size.height);
    auto sceneCpp = static_cast<spt::Scene*>(self.sceneHandle);
    spt::Camera::updatePerspectiveAspectRatio(sceneCpp->registry, self.viewCameraEntity, size.width / size.height);
//    SPTCameraUpdateOrthographicAspectRatio(self.viewCameraEntity, size.width / size.height);
}

@end
