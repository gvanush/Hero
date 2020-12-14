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
    return [[Transform alloc] initWithUnownedCpp: self.cpp->get<hero::Transform>()];
}

-(Camera *)camera {
    return [[Camera alloc] initWithUnownedCpp: self.cpp->get<hero::Camera>()];
}

-(ImageRenderer *)imageRenderer {
    return [[ImageRenderer alloc] initWithUnownedCpp: self.cpp->get<hero::ImageRenderer>()];
}

@end

@implementation SceneObject (Cpp)

-(hero::SceneObject*) cpp {
    return static_cast<hero::SceneObject*>(self.cppHandle);
}

@end
