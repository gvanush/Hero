//
//  HeroScene.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "CppWrapper.h"
#import "Layer.h"

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@class RenderingContext;
@class Camera;

NS_ASSUME_NONNULL_BEGIN

@interface HeroScene: CppWrapper

-(void) addLayer: (Layer*) layer;

-(void) render: (RenderingContext*) renderingContext;

@property (nonatomic, readwrite) simd_float4 bgrColor;
@property (nonatomic, readwrite) simd_float2 viewportSize;
@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readonly) NSArray* layers;
@property (nonatomic, readonly) Camera* viewCamera;

@end

#ifdef __cplusplus

namespace hero { class Scene; }

@interface HeroScene (Cpp)

-(hero::Scene*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
