//
//  Device.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 25.11.21.
//

#pragma once

#include "Base.hpp"
#include "APIObjectWrapper.hpp"
#include "ResourceOptions.hpp"

namespace spt::ghi {

class Buffer;

class Device: public APIObjectWrapper {
public:
    
    static Device& systemDefault();
    
    Buffer* newBuffer(const void* data, UInt length, StorageMode stoargeMode, CPUCacheMode cacheMode = CPUCacheMode::default_, HazardTrackingMode hazardTrackingMode = HazardTrackingMode::default_);
    
private:
    using APIObjectWrapper::APIObjectWrapper;
};

}
