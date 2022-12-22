//
//  SPTViewController.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Base.h"

#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

@class SPTRenderingContext;

NS_ASSUME_NONNULL_BEGIN

@interface SPTViewController : UIViewController

-(instancetype) initWithSceneHandle: (SPTHandle) sceneHandle NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithCoder: (NSCoder*) coder NS_UNAVAILABLE;
-(instancetype) initWithNibName: (NSString* _Nullable) nibNameOrNil bundle: (NSBundle* _Nullable) nibBundleOrNil NS_UNAVAILABLE;

-(void) setRenderingPaused: (BOOL) paused;
    
@property (nonatomic, readonly) SPTHandle sceneHandle;
@property (nonatomic, readwrite) SPTEntity viewCameraEntity;
@property (nonatomic, readonly) MTKView* mtkView;
@property (nonatomic, readonly) SPTRenderingContext* renderingContext;

@end

NS_ASSUME_NONNULL_END
