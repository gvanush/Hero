//
//  VideoRenderer.h
//  Hero
//
//  Created by Vanush Grigoryan on 2/5/21.
//

#import "Component.h"
#import "TextureUtilsCommon.h"
#import "Material.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoRenderer: Component

@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readwrite) id<VideoMaterial> material;

@end

#ifdef __cplusplus

namespace hero { class VideoRenderer; }

@interface VideoRenderer (Cpp)

-(hero::VideoRenderer*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
