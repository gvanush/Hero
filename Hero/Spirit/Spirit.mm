//
//  Spirit.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Spirit.h"
#include "MeshRenderer.hpp"

#import "RenderingContext.h"


void spt_init() {
    [RenderingContext setup];
    spt::MeshRenderer::init();
}
