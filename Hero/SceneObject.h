//
//  SceneObject.h
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"

@class Transform;

NS_ASSUME_NONNULL_BEGIN

@interface SceneObject : CppWrapper

-(instancetype) init;

@property (nonatomic, copy) NSString* name;
@property (nonatomic, readonly) Transform* transform;

@end

#ifdef __cplusplus

namespace hero { class SceneObject; }

@interface SceneObject (Cpp)

-(hero::SceneObject*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
