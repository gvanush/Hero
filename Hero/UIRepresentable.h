//
//  UIRepresentable.h
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "CppOwner.h"
#import "Renderer_Common.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIRepresentable: CppOwner

-(instancetype) init NS_UNAVAILABLE;

-(void) onUIUpdated: (RendererFlag) flag;
-(bool) needsUIUpdate: (RendererFlag) flag;

@end

#ifdef __cplusplus

namespace hero { class UIRepresentable; }

@interface UIRepresentable (Cpp)

-(hero::UIRepresentable*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
