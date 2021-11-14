//
//  SPTScene.h
//  Hero
//
//  Created by Vanush Grigoryan on 11.11.21.
//

#import "Common.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPTScene : NSObject

-(spt_entity) makeEntity;

+(void) destroyEntity: (spt_entity) entity;

-(spt_scene_handle) cpp;

@end

NS_ASSUME_NONNULL_END
