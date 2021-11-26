//
//  Buffer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 26.11.21.
//

#pragma once

#include "APIObjectWrapper.hpp"

namespace spt::ghi {

class Buffer: public APIObjectWrapper {
private:
    using APIObjectWrapper::APIObjectWrapper;
    
    friend class Device;
};

}
