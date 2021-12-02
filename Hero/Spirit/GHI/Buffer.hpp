//
//  Buffer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 26.11.21.
//

#pragma once

#include "APIObjectWrapper.hpp"
#include "Base.hpp"

namespace spt::ghi {

class Buffer: public APIObjectWrapper {
public:
    
    void* data() const;
    UInt size() const;
    
private:
    using APIObjectWrapper::APIObjectWrapper;
    
    friend class Device;
};

}
