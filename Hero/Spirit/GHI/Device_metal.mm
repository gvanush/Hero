//
//  Device_metal.mm
//  Hero
//
//  Created by Vanush Grigoryan on 25.11.21.
//

#include "Device.hpp"
#include "Buffer.hpp"

#import "ResourceOptionsUtil_metal.h"

#import <Metal/Metal.h>

namespace spt::ghi {

Device& Device::systemDefault() {
    static Device device {(__bridge void*) MTLCreateSystemDefaultDevice()};
    return device;
}

Buffer* Device::newBuffer(const void* data, UInt length, StorageMode stoargeMode, CPUCacheMode cacheMode, HazardTrackingMode hazardTrackingMode) {
    auto mtlDevice = (__bridge id<MTLDevice>) apiObject();
    auto mtlBuffer = [mtlDevice newBufferWithBytes: data length: length options: toMTLResourceOptions(stoargeMode) | toMTLResourceOptions(cacheMode) | toMTLResourceOptions(hazardTrackingMode)];
    return new Buffer{(__bridge void*) mtlBuffer};
}

}
