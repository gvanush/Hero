//
//  SphericalCoord.h
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"

#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface SphericalCoord: CppWrapper

-(simd_float3) getPosition;

@property (nonatomic, readwrite) simd_float3 center;
@property (nonatomic, readwrite) float radius;
@property (nonatomic, readwrite) float longitude;
@property (nonatomic, readwrite) float latitude;
@property (nonatomic, readwrite) float radiusFactor;

@end

#ifdef __cplusplus

namespace hero { class SphericalCoord; }

@interface SphericalCoord (Cpp)

-(hero::SphericalCoord*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
