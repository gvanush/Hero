//
//  CppWrapper.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus

#include "ObjCWrappee.hpp"

#endif

typedef void* CppHandle;
typedef void (^CppHandleDeleter) (CppHandle handle);

@interface CppWrapper: NSObject

@property (nonatomic, readonly) CppHandle cppHandle;

#ifdef __cplusplus

-(instancetype) initWithOwnedCpp: (hero::ObjCWrappee*) cpp deleter: (CppHandleDeleter) deleter NS_DESIGNATED_INITIALIZER;
-(instancetype) initWithCpp: (hero::ObjCWrappee*) cpp;
-(instancetype) init NS_UNAVAILABLE;

#endif

@end
