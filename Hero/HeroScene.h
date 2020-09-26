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

NS_ASSUME_NONNULL_BEGIN

@interface HeroScene: NSObject <CppWrapper>

@property (nonatomic, readwrite) simd_float4 bgrColor;
@property (nonatomic, readwrite) simd_float2 viewportSize;
@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readonly) NSArray* layers;

-(void) addLayer: (Layer*) layer;

-(void) render: (RenderingContext*) renderingContext;

@end

NS_ASSUME_NONNULL_END
