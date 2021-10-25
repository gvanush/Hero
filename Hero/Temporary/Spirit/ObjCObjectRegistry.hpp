//
//  ObjCObjectRegistry.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/14/21.
//

#pragma once

#include <unordered_map>

class ObjCObjectRegistry {
public:
    
    static ObjCObjectRegistry& shared() {
        static ObjCObjectRegistry object;
        return object;
    }
    
    void addObject(void* objC, void* cpp) {
        assert(_cppToObjC.find(cpp) == _cppToObjC.end());
        _cppToObjC[cpp] = objC;
    }
    
    void* getObjectFor(void* cpp) {
        if (const auto it = _cppToObjC.find(cpp); it != _cppToObjC.end()) {
            return it->second;
        }
        return nullptr;
    }
    
    void removeObjectFor(void* cpp) {
        _cppToObjC.erase(cpp);
    }
    
    ObjCObjectRegistry(const ObjCObjectRegistry&) = delete;
    ObjCObjectRegistry& operator=(const ObjCObjectRegistry&) = delete;
    
private:
    
    ObjCObjectRegistry() = default;
    
    std::unordered_map<void*, void*> _cppToObjC;
};
