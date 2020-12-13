//
//  LineRenderer.h
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#import "Component.h"

#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface LineRenderer: Component

@property (nonatomic, readonly) simd_float3 point1;
@property (nonatomic, readonly) simd_float3 point2;
@property (nonatomic, readwrite) float thickness;
@property (nonatomic, readwrite) simd_float4 color;

@end

#ifdef __cplusplus

namespace hero { class LineRenderer; }

@interface LineRenderer (Cpp)

-(hero::LineRenderer*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
