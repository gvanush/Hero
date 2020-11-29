//
//  UIRepresentable.mm
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "UIRepresentable.h"
#import "Renderer.h"

#include "UIRepresentable.hpp"

@implementation UIRepresentable

-(void) onUIUpdated: (RendererFlag) flag {
    self.cpp->onUIUpdated(flag);
}

-(bool) needsUIUpdate: (RendererFlag) flag {
    return self.cpp->needsUIUpdate(flag);
}

-(void) dealloc {
    [Renderer removeAllObserversFor: self];
    delete self.cpp;
    [self resetCpp];
}

@end

@implementation UIRepresentable (Cpp)

-(hero::UIRepresentable*) cpp {
    return static_cast<hero::UIRepresentable*>(self.cppHandle);
}

@end
