//
//  ObjCProxy.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/31/21.
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>

namespace hero {

class ObjCProxy {
public:
    
    ObjCProxy();
    explicit ObjCProxy(CFTypeRef objC);
    ObjCProxy(const ObjCProxy& proxy);
    ObjCProxy(ObjCProxy&& proxy);
    ~ObjCProxy();
    
    ObjCProxy& operator=(const ObjCProxy& proxy);
    ObjCProxy& operator=(ObjCProxy&& proxy);
    
    bool operator == (const ObjCProxy& proxy) const;
    bool operator != (const ObjCProxy& proxy) const;
    
    operator bool () const;
    
    inline CFTypeRef handle() const;
    
private:
    void safeRetain();
    void safeRelease();
    
    CFTypeRef _handle;
};

CFTypeRef ObjCProxy::handle() const {
    return _handle;
}

}
