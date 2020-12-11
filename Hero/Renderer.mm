//
//  Renderer.mm
//  Hero
//
//  Created by Vanush Grigoryan on 11/4/20.
//

#import "Renderer.h"
#import "UIRepresentable.h"
#import "NSPointerArray+Extensions.h"
#import "RenderingContext.h"
#import "Scene.h"

#include "Renderer.hpp"

@interface Renderer () {
    NSMapTable<UIRepresentable*, NSPointerArray*>* _uiRepresentableToObservers;
    BOOL _isUpdatingUI;
}

@end

@implementation Renderer

+(instancetype __nullable) make {
    if (Renderer* renderer = [[Renderer alloc] initWithOwnedCpp: hero::Renderer::make() deleter:^(CppHandle handle) {
        delete static_cast<hero::Renderer*>(handle);
    }]) {
        renderer->_uiRepresentableToObservers = [NSMapTable weakToStrongObjectsMapTable];
        renderer->_isUpdatingUI = false;
        return renderer;
    }
    return nil;
}

#pragma mark - UI update
-(void) addObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
    if (!observers) {
        observers = [NSPointerArray weakObjectsPointerArray];
        [_uiRepresentableToObservers setObject: observers forKey: uiRepresentable];
    }
    [observers addPointer: (__bridge void * _Nullable)(observer)];
}

-(void) removeObserver: (id<UIRepresentableObserver>) observer for: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
    NSUInteger index = [observers indexOfObjectPassingTest:^BOOL(id  _Nonnull object) {
        // Checking for 'nil' is needed becasue if the method is called
        // from the destructor of observer it is alread 'nil' in observers array
        return object == observer || object == nil;
    }];
    if(index != NSNotFound) {
        [observers removePointerAtIndex: index];
    }
}

-(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable {
    NSAssert(!_isUpdatingUI, @"");
    
    [_uiRepresentableToObservers removeObjectForKey: uiRepresentable];
}

+(void) removeAllObserversFor: (UIRepresentable*) uiRepresentable {
    // TODO: 
    /*
    for(auto renderer: hero::Renderer::allRenderers()) {
        if (renderer) {
            [renderer->objC<Renderer*>() removeAllObserversFor: uiRepresentable];
        }
    }
     */
}

-(void) render: (Scene*) scene context: (RenderingContext*) context {
    self.cpp->render(*scene.cpp, *context.cpp);
    
    _isUpdatingUI = true;
    
    for (UIRepresentable* uiRepresentable in _uiRepresentableToObservers) {
        if ([uiRepresentable needsUIUpdate: self.cpp->flag()]) {
            NSPointerArray* observers = [_uiRepresentableToObservers objectForKey: uiRepresentable];
            for (id<UIRepresentableObserver> observer in observers) {
                [observer onUIUpdateRequired];
            }
            [uiRepresentable onUIUpdated: self.cpp->flag()];
        }
    }
    
    _isUpdatingUI = false;
    
}

+(void) setup {
    hero::Renderer::setup();
}

@end

@implementation Renderer (Cpp)

-(hero::Renderer*) cpp {
    return static_cast<hero::Renderer*>(self.cppHandle);
}

@end
