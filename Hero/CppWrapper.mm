//
//  CppPair.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"

#include "ObjCObjectRegistry.hpp"

@interface CppWrapper () {
    void* _cpp;
    CppDeleter _deleter;
}
    
-(instancetype) initWithUnownedCpp: (void*) cpp NS_DESIGNATED_INITIALIZER;

@end

@implementation CppWrapper

-(instancetype) initWithOwnedCpp: (void*) cpp deleter: (CppDeleter) deleter {
    if (self = [super init]) {
        if (!cpp) {
            return nil;
        }
        _cpp = cpp;
        _deleter = deleter;
        ObjCObjectRegistry::shared().addObject((__bridge void*) self, cpp);
    }
    return self;
}

-(instancetype) initWithUnownedCpp: (void*) cpp {
    if (self = [super init]) {
        if (!cpp) {
            return nil;
        }
        _cpp = cpp;
        _deleter = nullptr;
        ObjCObjectRegistry::shared().addObject((__bridge void*) self, cpp);
    }
    return self;
}

+(instancetype) wrapperForCpp: (void*) cpp {
    
    if (auto objC = ObjCObjectRegistry::shared().getObjectFor(cpp)) {
        return (__bridge id) objC;
    }
    
    // If there is no matching ObjC object in registry it means C++ object is not owned
    return [[self alloc] initWithUnownedCpp: cpp];
}

-(void) dealloc {
    if(_deleter) {
        _deleter(_cpp);
        _cpp = nullptr;
    }
    ObjCObjectRegistry::shared().removeObjectFor(_cpp);
}

-(void*) cppHandle {
    return _cpp;
}

@end
