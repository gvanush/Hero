//
//  CppWrapper.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void* CppHandle;
typedef void (^CppHandleDeleter) (CppHandle handle);

@interface CppWrapper: NSObject

@property (nonatomic, readonly) CppHandle cppHandle;

#ifdef __cplusplus

-(instancetype) initWithOwnedCpp: (CppHandle) cpp deleter: (CppHandleDeleter) deleter NS_DESIGNATED_INITIALIZER;
-(instancetype) init NS_UNAVAILABLE;

+(instancetype) wrapperWithUnownedCpp: (CppHandle) cpp;

#endif

@end

NS_ASSUME_NONNULL_END
