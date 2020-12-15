//
//  SceneObject.m
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "SceneObject.h"
#import "Transform.h"
#import "Camera.h"
#import "ImageRenderer.h"

#include "SceneObject.hpp"
#include "Transform.hpp"
#include "Camera.hpp"
#include "LineRenderer.hpp"
#include "ImageRenderer.hpp"

@implementation SceneObject

-(Transform *)transform {
    return [Transform wrapperWithUnownedCpp: self.cpp->get<hero::Transform>()];
}

-(Camera *)camera {
    return [Camera wrapperWithUnownedCpp: self.cpp->get<hero::Camera>()];
}

-(ImageRenderer *)imageRenderer {
    return [ImageRenderer wrapperWithUnownedCpp: self.cpp->get<hero::ImageRenderer>()];
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
