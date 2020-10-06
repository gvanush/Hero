//
//  Camera.h
//  Hero
//
//  Created by Vanush Grigoryan on 9/30/20.
//

#import "SceneObject.h"
#import "Geometry.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Camera: SceneObject

-(instancetype) initWithNear: (float) near far: (float) far aspectRatio: (float) aspectRatio;

-(simd_float4) convertToWorld: (simd_float4) vec fromViewportWithSize: (Size2) viewportSize;

@property (nonatomic, readwrite) float aspectRatio;
@property (nonatomic, readwrite) float fovy;
@property (nonatomic, readwrite) float orthographicScale;
@property (nonatomic, readwrite) float near;
@property (nonatomic, readwrite) float far;
@property (nonatomic, readwrite) Projection projection;

-(void) lookAt: (simd_float3) point up: (simd_float3) up;

@end

#ifdef __cplusplus

namespace hero { class Camera; }

@interface Camera (Cpp)

-(hero::Camera*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
