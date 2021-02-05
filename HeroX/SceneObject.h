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
@class TextureRenderer;
@class VideoRenderer;

NS_ASSUME_NONNULL_BEGIN

@interface SceneObject : CppWrapper

@property (nonatomic, copy) NSString* name;
@property (nonatomic, readonly) Transform* __nullable transform;
@property (nonatomic, readonly) Camera* __nullable camera;
@property (nonatomic, readonly) TextureRenderer* __nullable textureRenderer;
@property (nonatomic, readonly) VideoRenderer* __nullable videoRenderer;

@end

#ifdef __cplusplus

namespace hero { class SceneObject; }

@interface SceneObject (Cpp)

-(hero::SceneObject*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
