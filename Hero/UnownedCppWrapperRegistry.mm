//
//  UnownedCppWrapperRegistry.mm
//  Hero
//
//  Created by Vanush Grigoryan on 12/15/20.
//

#import "UnownedCppWrapperRegistry.h"
#import "CppWrapper.h"

#include <cassert>

namespace hero {

void UnownedCppWrapperRegistry::addWrapper(CppWrapper* wrapper) {
    assert(wrapper);
    assert(wrapper.cppHandle);
    assert(_cppToObjC.find(wrapper.cppHandle) == _cppToObjC.end());
    _cppToObjC[wrapper.cppHandle] = (__bridge_retained void*) wrapper;
}

void UnownedCppWrapperRegistry::removeWrapperFor(void* cpp) {
    assert(cpp);
    auto it = _cppToObjC.find(cpp);
    if (it == _cppToObjC.end()) {
        return;
    }
    CFRelease(it->second);
    _cppToObjC.erase(it);
}

UnownedCppWrapperRegistry::~UnownedCppWrapperRegistry() {
    for(auto& item: _cppToObjC) {
        CFRelease(item.second);
    }
}

UnownedCppWrapperRegistry& UnownedCppWrapperRegistry::shared() {
    static UnownedCppWrapperRegistry shared;
    return shared;
}

}
