//
//  ObjectProperty.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "AnimatorBinding.h"
#include "ObjectProperty.h"


namespace spt {

template <SPTObjectProperty P>
struct AnimatorBinding {
    SPTAnimatorBinding base;
};

};
