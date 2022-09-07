//
//  SPTPlayableScene.h
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#import "Base.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SPTScene;

@interface SPTPlayableScene : NSObject

-(instancetype)init NS_UNAVAILABLE;

-(SPTSceneHandle) cpp;

+(SPTPlayableScene*) makeFromScene: (SPTScene*) scene viewCameraEntity: (SPTEntity) viewCameraEntity;

-(SPTEntity) viewCameraEntity;

@end

NS_ASSUME_NONNULL_END
