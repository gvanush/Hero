//
//  Buffer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 26.11.21.
//

#include "Buffer.hpp"

#import <Metal/Metal.h>

namespace spt::ghi {

void* Buffer::data() const {
    return [(__bridge id<MTLBuffer>) apiObject() contents];
}

UInt Buffer::size() const {
    return [(__bridge id<MTLBuffer>) apiObject() length];
}

}
