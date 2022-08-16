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

template <SPTAnimatableObjectProperty P>
struct AnimatorBinding {
    SPTAnimatorBinding base;
};

};
