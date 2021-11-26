//
//  APIObjectWrapper.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 25.11.21.
//

#include "APIObjectWrapper.hpp"
#include "Base.hpp"

#ifdef SPT_GHI_METAL

#include <CoreFoundation/CoreFoundation.h>

#endif

namespace spt::ghi {

APIObjectWrapper::APIObjectWrapper(void* apiObject)
: _apiObject{apiObject} {
    assert(_apiObject);
#ifdef SPT_GHI_METAL
    CFRetain(_apiObject);
#endif
}

APIObjectWrapper::~APIObjectWrapper() {
#ifdef SPT_GHI_METAL
    CFRelease(_apiObject);
#endif
}

}
