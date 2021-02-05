//
//  SceneObject.m
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "SceneObject.h"
#import "Transform.h"
#import "Camera.h"
#import "TextureRenderer.h"
#import "VideoRenderer.h"

#include "SceneObject.hpp"
#include "Transform.hpp"
#include "Camera.hpp"
#include "LineRenderer.hpp"
#include "TextureRenderer.hpp"
#include "VideoRenderer.hpp"

@implementation SceneObject

-(Transform *)transform {
    return [Transform wrapperForCpp: self.cpp->get<hero::Transform>()];
}

-(Camera *)camera {
    return [Camera wrapperForCpp: self.cpp->get<hero::Camera>()];
}

-(TextureRenderer *)textureRenderer {
    return [TextureRenderer wrapperForCpp: self.cpp->get<hero::TextureRenderer>()];
}

-(VideoRenderer *) videoRenderer {
    return [VideoRenderer wrapperForCpp: self.cpp->get<hero::VideoRenderer>()];
}

-(void)setName:(NSString *)name {
    self.cpp->setName(name.UTF8String);
}

-(NSString *)name {
    return [[NSString alloc] initWithUTF8String: self.cpp->name().c_str()];
}

@end

@implementation SceneObject (Cpp)

-(hero::SceneObject*) cpp {
    return static_cast<hero::SceneObject*>(self.cppHandle);
}

@end
