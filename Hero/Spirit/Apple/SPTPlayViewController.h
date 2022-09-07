//
//  SPTPlayViewController.h
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#include "Base.h"

#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

@class SPTPlayableScene;
@class SPTRenderingContext;

NS_ASSUME_NONNULL_BEGIN

@interface SPTPlayViewController : UIViewController

-(instancetype) initWithScene: (SPTPlayableScene*) scene NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithCoder: (NSCoder*) coder NS_UNAVAILABLE;
-(instancetype) initWithNibName: (NSString* _Nullable) nibNameOrNil bundle: (NSBundle* _Nullable) nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic, readonly) SPTPlayableScene* scene;
@property (nonatomic, readwrite) SPTEntity viewCameraEntity;
@property (nonatomic, readonly) MTKView* mtkView;
@property (nonatomic, readonly) SPTRenderingContext* renderingContext;

@property (nonatomic, readwrite) NSValue* _Nullable panLocation;

@end

NS_ASSUME_NONNULL_END
