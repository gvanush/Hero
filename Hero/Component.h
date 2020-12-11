//
//  Component.h
//  Hero
//
//  Created by Vanush Grigoryan on 12/11/20.
//

#import "CppWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface Component: CppWrapper

-(instancetype)initWithOwnedCpp:(CppHandle)cpp deleter:(CppHandleDeleter)deleter NS_UNAVAILABLE;

@end

#ifdef __cplusplus

namespace hero { class Component; }

@interface Component (Cpp)

-(hero::Component*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
