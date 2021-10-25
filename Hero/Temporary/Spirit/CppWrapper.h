//
//  CppWrapper.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CppDeleter) (void* pair);

@interface CppWrapper: NSObject

-(instancetype) init NS_UNAVAILABLE;
-(instancetype) initWithOwnedCpp: (void*) cpp deleter: (CppDeleter) deleter NS_DESIGNATED_INITIALIZER;

+(instancetype) wrapperForCpp: (void*) cpp;

@property (nonatomic, readonly) void* cppHandle;

@end

NS_ASSUME_NONNULL_END
