//
//  Transform.h
//  Hero
//
//  Created by Vanush Grigoryan on 12/9/20.
//

#import "CppWrapper.h"
#import "GeometryUtils_Common.h"

#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface Transform: CppWrapper

@property (nonatomic, readwrite) simd_float3 position;
@property (nonatomic, readwrite) simd_float3 scale;
@property (nonatomic, readwrite) simd_float3 rotation;
@property (nonatomic, readwrite) EulerOrder eulerOrder;
@property (nonatomic, readonly) simd_float4x4 worldMatrix;

@end

#ifdef __cplusplus

namespace hero { class Transform; }

@interface Transform (Cpp)

-(hero::Transform*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
