//
//  Object.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/2/20.
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>

namespace hero {

using ObjCHandle = CFTypeRef;

class Object {
public:

    ~Object() {
        _objCHandle = nullptr;
    }
    
    inline ObjCHandle objCHandle() const {
        return _objCHandle;
    }
    
#ifdef __OBJC__
    
    template <typename T>
    inline T objC() const {
        return (__bridge T) _objCHandle;
    }
    
    inline void setObjCHandle(ObjCHandle handle) {
        _objCHandle = handle;
    }
    
#endif
    
private:
    ObjCHandle _objCHandle = nullptr;
    
};

}
