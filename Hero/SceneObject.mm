//
//  SceneObject.m
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "SceneObject.h"
#import "Transform.h"
#import "Camera.h"

#include "SceneObject.hpp"
#include "Transform.hpp"
#include "Camera.hpp"

@implementation SceneObject

-(instancetype) init {
    return [self initWithOwnedCpp: new hero::SceneObject {} deleter:^(CppHandle handle) {
        delete static_cast<hero::SceneObject*>(handle);
    }];
}

-(Transform *)transform {
    return [[Transform alloc] initWithUnownedCpp: self.cpp->get<hero::Transform>()];
}

-(Camera *)camera {
    return [[Camera alloc] initWithUnownedCpp: self.cpp->get<hero::Camera>()];
}

+(SceneObject*) makeBasic {
    // TODO: must not be owned
    return [[SceneObject alloc] initWithOwnedCpp: hero::SceneObject::makeBasic() deleter:^(CppHandle handle) {
        delete static_cast<hero::SceneObject*>(handle);
    }];
}

@end

@implementation SceneObject (Cpp)

-(hero::SceneObject*) cpp {
    return static_cast<hero::SceneObject*>(self.cppHandle);
}

@end
