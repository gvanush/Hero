//
//  SPTScene.h
//  Hero
//
//  Created by Vanush Grigoryan on 11.11.21.
//

#import "Base.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPTScene : NSObject

-(SPTObject) makeEntity;

+(void) destroyEntity: (SPTObject) entity;

-(SPTSceneHandle) cpp;

@end

NS_ASSUME_NONNULL_END
