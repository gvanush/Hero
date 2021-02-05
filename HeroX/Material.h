//
//  VideoMaterial.h
//  Hero
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@protocol Material <NSObject>
@end

@protocol DynamicMaterial <Material>
@required
-(void) update;

@end

@protocol VideoMaterial <DynamicMaterial>
@required

-(id<MTLTexture>) lumaTexture;
-(id<MTLTexture>) chromaTexture;

@end

NS_ASSUME_NONNULL_END
