//
//  ObjCProxy.cpp
//  HeroX
//
//  Created by Vanush Grigoryan on 1/31/21.
//

#include "ObjCProxy.hpp"

namespace hero {

ObjCProxy::ObjCProxy()
: _handle {nullptr} {
}

ObjCProxy::ObjCProxy(CFTypeRef objC)
: _handle {objC} {
    safeRetain();
}

ObjCProxy::ObjCProxy(const ObjCProxy& proxy) {
    _handle = proxy._handle;
    safeRetain();
}

ObjCProxy::ObjCProxy(ObjCProxy&& proxy) {
    _handle = proxy._handle;
    proxy._handle = nullptr;
}

ObjCProxy::~ObjCProxy() {
    safeRelease();
    _handle = nullptr;
}

ObjCProxy& ObjCProxy::operator=(const ObjCProxy& proxy) {
    if (*this != proxy) {
        safeRelease();
        _handle = proxy._handle;
        safeRetain();
    }
    return *this;
}

ObjCProxy& ObjCProxy::operator=(ObjCProxy&& proxy) {
    if(*this != proxy) {
        safeRelease();
        _handle = proxy._handle;
        proxy._handle = nullptr;
    }
    return *this;
}

bool ObjCProxy::operator == (const ObjCProxy& proxy) const {
    return _handle == proxy._handle;
}

bool ObjCProxy::operator != (const ObjCProxy& proxy) const {
    return !(*this == proxy);
}

ObjCProxy::operator bool () const {
    return _handle;
}

void ObjCProxy::safeRetain() {
    if(_handle) {
        CFRetain(_handle);
    }
}

void ObjCProxy::safeRelease() {
    if(_handle) {
        CFRelease(_handle);
    }
}

}
