//
//  SceneObject.h
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"
#import "Geometry.h"

#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface SceneObject : CppWrapper

@property (nonatomic, readwrite) simd_float3 position;
@property (nonatomic, readwrite) simd_float3 scale;
@property (nonatomic, readwrite) simd_float3 rotation;
@property (nonatomic, readwrite) EulerOrder eulerOrder;
@property (nonatomic, readwrite) simd_float4x4 worldMatrix;

@end

#ifdef __cplusplus

namespace hero { class SceneObject; }

@interface SceneObject (Cpp)

-(hero::SceneObject*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END