//
//  Line.h
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#import "SceneObject.h"

#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface Line: SceneObject

-(instancetype) initWithPoint1: (simd_float3) point1 point2: (simd_float3) point2 thickness: (float) thickness color: (simd_float4) color;
-(instancetype) initWithPoint1: (simd_float3) point1 point2: (simd_float3) point2;

@property (nonatomic, readwrite) simd_float3 point1;
@property (nonatomic, readwrite) simd_float3 point2;
@property (nonatomic, readwrite) float thickness;
@property (nonatomic, readwrite) simd_float4 color;

@end

#ifdef __cplusplus

namespace hero { class Line; }

@interface Line (Cpp)

-(hero::Line*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
