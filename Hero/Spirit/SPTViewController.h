//
//  SPTViewController.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#import "SPTScene.h"

#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

@class RenderingContext;

NS_ASSUME_NONNULL_BEGIN

@interface SPTViewController : UIViewController

-(instancetype) initWithScene: (SPTScene*) scene NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithCoder: (NSCoder*) coder NS_UNAVAILABLE;
-(instancetype) initWithNibName: (NSString* _Nullable) nibNameOrNil bundle: (NSBundle* _Nullable) nibBundleOrNil NS_UNAVAILABLE;

@property (nonatomic, readonly) SPTScene* scene;
@property (nonatomic, readwrite) spt_entity viewCameraEntity;
@property (nonatomic, readonly) MTKView* mtkView;
@property (nonatomic, readonly) RenderingContext* renderingContext;

@end

NS_ASSUME_NONNULL_END
