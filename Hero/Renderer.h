//
//  Renderer.h
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "CppOwner.h"
#import "UIRepresentableObserver.h"

#import <MetalKit/MetalKit.h>

@class UIRepresentable;
@class Scene;
@class RenderingContext;

NS_ASSUME_NONNULL_BEGIN

@interface Renderer : CppOwner

-(instancetype) init NS_UNAVAILABLE;

+(instancetype __nullable) make;

-(void) addObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable NS_SWIFT_NAME(addObserver(_:for:));
-(void) removeObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable NS_SWIFT_NAME(removeObserver(_:for:));
-(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable;

+(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable;

-(void) render: (Scene*) scene context: (RenderingContext*) context;

+(void) setup;

@end

#ifdef __cplusplus

namespace hero { class Renderer; }

@interface Renderer (Cpp)

-(hero::Renderer*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
