//
//  Scene.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "UIRepresentable.h"
#import "SceneObject.h"
#import "GeometryUtils_Common.h"

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@class Camera;

NS_ASSUME_NONNULL_BEGIN

@interface Scene: UIRepresentable

-(instancetype) init;
-(instancetype) initWithUnownedCpp: (CppHandle) cpp NS_UNAVAILABLE;

-(SceneObject*) createObject;
-(SceneObject*) makeLinePoint1: (simd_float3) point1 point2: (simd_float3) point2 thickness: (float) thickness color: (simd_float4) color NS_SWIFT_NAME(makeLine(point1:point2:thickness:color:));
-(SceneObject*) makeImage;

-(void) removeObject: (SceneObject*) object;

-(SceneObject* _Nullable) rayCast: (Ray) ray;

@property (nonatomic, readwrite) simd_float4 bgrColor;
@property (nonatomic, readonly) SceneObject* viewCamera;
@property (nonatomic, readwrite) SceneObject* _Nullable selectedObject;

@end

#ifdef __cplusplus

namespace hero { class Scene; }

@interface Scene (Cpp)

-(hero::Scene*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
