//
//  CppOwner.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppOwner.h"

@implementation CppOwner

-(instancetype) initWithCpp: (hero::Object*) cpp {
    if (!cpp) {
        return nil;
    }
    if (self = [super init]) {
        _cppHandle = cpp;
        cpp->setObjCHandle((__bridge hero::ObjCHandle) self);
    }
    return self;
}

-(void) resetCpp; {
    _cppHandle = nullptr;
}

@end
