//
//  CppWrapper.m
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "CppWrapper.h"

@implementation CppWrapper

-(instancetype) initWithCppHandle: (CppHandle) cppHandle {
    if (self = [super init]) {
        _cppHandle = cppHandle;
    }
    return self;
}

-(void) dealloc {
    _cppHandle = nullptr;
}

@end
