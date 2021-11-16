//
//  Spirit.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Spirit.h"
#include "MeshRenderer.hpp"

#import "SPTRenderingContext.h"


void spt_init() {
    [SPTRenderingContext setup];
    spt::MeshRenderer::init();
}
