//
//  Component.mm
//  Hero
//
//  Created by Vanush Grigoryan on 12/11/20.
//

#import "Component.h"

#include "Component.hpp"

@implementation Component

@end

@implementation Component (Cpp)

-(hero::Component*) cpp {
    return static_cast<hero::Component*>(self.cppHandle);
}

@end
