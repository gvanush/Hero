//
//  CppOwner.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus

#include "Object.hpp"

#endif

typedef void* CppHandle;

@interface CppOwner: NSObject

@property (nonatomic, readonly) CppHandle cppHandle;

#ifdef __cplusplus

-(instancetype) initWithCpp: (hero::Object*) cpp;

-(void) resetCpp;

#endif

@end
