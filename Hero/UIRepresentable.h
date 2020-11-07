//
//  UIRepresentable.h
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "CppOwner.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIRepresentable: CppOwner

-(instancetype) init NS_UNAVAILABLE;

-(void) onUIUpdated;

@property (nonatomic, readonly) bool needsUIUpdate;

@end

#ifdef __cplusplus

namespace hero { class UIRepresentable; }

@interface UIRepresentable (Cpp)

-(hero::UIRepresentable*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
