//
//  SceneObject.h
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"

#import <simd/simd.h>

@class Transform;
@class Camera;

NS_ASSUME_NONNULL_BEGIN

@interface SceneObject : CppWrapper

-(instancetype) init;
// TODO:
/*-(instancetype) initWithOwnedCpp: (CppHandle)cpp deleter:(CppHandleDeleter)deleter NS_UNAVAILABLE;
-(instancetype) initWithUnownedCpp: (CppHandle) cpp NS_UNAVAILABLE;*/

@property (nonatomic, copy) NSString* name;
@property (nonatomic, readonly) Transform* transform;
@property (nonatomic, readonly) Camera* camera;

+(SceneObject*) makeBasic;
+(SceneObject*) makeLinePoint1: (simd_float3) point1 point2: (simd_float3) point2 thickness: (float) thickness color: (simd_float4) color;

@end

#ifdef __cplusplus

namespace hero { class SceneObject; }

@interface SceneObject (Cpp)

-(hero::SceneObject*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
