//
//  UnownedCppWrapperRegistry.h
//  Hero
//
//  Created by Vanush Grigoryan on 12/15/20.
//

#include <CoreFoundation/CoreFoundation.h>
#include <unordered_map>

#ifdef __OBJC__

@class CppWrapper;

#endif

namespace hero {

class UnownedCppWrapperRegistry {
public:
    
#ifdef __OBJC__
    
    inline CppWrapper* getWrapperFor(void* cpp) const {
        assert(cpp);
        if (auto it = _cppToObjC.find(cpp); it != _cppToObjC.end()) {
            return (__bridge CppWrapper*) it->second;
        }
        return nil;
    }
    
    void addWrapper(CppWrapper* wrapper);
    
#endif
    
    void removeWrapperFor(void* cpp);
    
    ~UnownedCppWrapperRegistry();
    
    static UnownedCppWrapperRegistry& shared();
    
private:
    
    UnownedCppWrapperRegistry() = default;
    UnownedCppWrapperRegistry(const UnownedCppWrapperRegistry&) = delete;
    UnownedCppWrapperRegistry& operator=(const UnownedCppWrapperRegistry&) = delete;
    
    std::unordered_map<void*, void*> _cppToObjC;
};

}
