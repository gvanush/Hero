//
//  CppWrapper.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#import <Foundation/Foundation.h>

typedef void* CppHandle;

@interface CppWrapper: NSObject

@property (nonatomic, readonly) CppHandle cppHandle;

#ifdef __cplusplus

-(instancetype) initWithCppHandle: (CppHandle) cppHandle;

#endif

@end
