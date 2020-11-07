//
//  UIRepresentable.mm
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "UIRepresentable.h"

#include "UIRepresentable.hpp"

@implementation UIRepresentable

-(void) onUIUpdated {
    self.cpp->onUIUpdated();
}

-(bool) needsUIUpdate {
    return self.cpp->needsUIUpdate();
}

-(void) dealloc {
    delete self.cpp;
}

@end

@implementation UIRepresentable (Cpp)

-(hero::UIRepresentable*) cpp {
    return static_cast<hero::UIRepresentable*>(self.cppHandle);
}

@end
