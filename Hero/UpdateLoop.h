//
//  UpdateLoop.h
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "UIRepresentableObserver.h"
#import "Scene.h"

#import <Foundation/Foundation.h>

@class UIRepresentable;

NS_ASSUME_NONNULL_BEGIN

@interface UpdateLoop : NSObject

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithScene: (Scene*) scene;

-(void) addObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable NS_SWIFT_NAME(addObserver(_:for:));
-(void) removeObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable NS_SWIFT_NAME(removeObserver(_:for:));
-(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable;

-(void) update;

@property (nonatomic, readonly) Scene* scene;

+(instancetype) shared;

@end

NS_ASSUME_NONNULL_END
