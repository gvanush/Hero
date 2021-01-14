//
//  Component.h
//  Hero
//
//  Created by Vanush Grigoryan on 12/11/20.
//

#import "UIRepresentable.h"

NS_ASSUME_NONNULL_BEGIN

@interface Component: UIRepresentable

@end

#ifdef __cplusplus

namespace hero { class Component; }

@interface Component (Cpp)

-(hero::Component*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
