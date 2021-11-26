//
//  Base.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 25.11.21.
//

#pragma once

#ifdef __APPLE__

#define SPT_GHI_METAL

#import <objc/NSObjCRuntime.h>

namespace spt::ghi {

using UInt = NSUInteger;
using Int = NSInteger;

}

#endif
