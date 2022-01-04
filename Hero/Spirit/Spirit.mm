//
//  Spirit.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Spirit.h"
#include "ResourceManager.hpp"
#include "Renderer.hpp"

#import "SPTRenderingContext.h"


void spt_init() {
    [SPTRenderingContext setup];
    spt::Renderer::init();
}
