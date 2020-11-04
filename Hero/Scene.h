//
//  Scene.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "CppOwner.h"
#import "SceneObject.h"

#import <Foundation/Foundation.h>
#import <simd/simd.h>

@class RenderingContext;
@class Camera;

NS_ASSUME_NONNULL_BEGIN

@interface Scene: CppOwner

-(void) addSceneObject: (SceneObject*) sceneObject;

-(SceneObject* _Nullable) rayCast;

-(void) render: (RenderingContext*) renderingContext;

@property (nonatomic, readwrite) simd_float4 bgrColor;
@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readonly) NSArray* sceneObjects;
@property (nonatomic, readonly) Camera* viewCamera;
@property (nonatomic, readwrite) SceneObject* _Nullable selectedObject;

+(void) setup;

@end

#ifdef __cplusplus

namespace hero { class Scene; }

@interface Scene (Cpp)

-(hero::Scene*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
